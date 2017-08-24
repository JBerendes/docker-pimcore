#!/bin/bash

set -xeuo pipefail

. /vars.sh

if ! test -e /etc/apache2/sites-enabled/000-default.conf; then
  sed -e "s|%%ROOT%%|$ROOT|g" < /tmp/vhost.conf > /etc/apache2/sites-enabled/000-default.conf
  rm /tmp/vhost.conf
fi

if ! test -e /etc/php/7.0/fpm/pool.d/www-data.conf; then
  sed -e "s|%%ROOT%%|$ROOT|g" < /tmp/www-data.conf > /etc/php/7.0/fpm/pool.d/www-data.conf
  rm /tmp/www-data.conf
fi

mkdir -p $INSTALLDIR
chown www-data $INSTALLDIR

# temp. start mysql to do all the install stuff
service mysql start

# download & extract
cd $INSTALLDIR
sudo -u www-data wget $PACKAGE_URL -O /tmp/pimcore.zip 
sudo -u www-data unzip -o /tmp/pimcore.zip -d $INSTALLDIR
rm /tmp/pimcore.zip 

while ! pgrep -o mysqld > /dev/null; do
  # ensure mysql is running properly
  sleep 1
done

# create demo mysql user
mysql -u root -e "CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'%' WITH GRANT OPTION;"

# setup database 
mysql ${DB_OPT} -e "CREATE DATABASE ${DATABASE} charset=utf8mb4;";

if test "$RELEASE" = "demo"; then
  mysql ${DB_OPT} ${DATABASE} < ${ROOT}/pimcore/modules/install/mysql/install.sql
  mysql ${DB_OPT} ${DATABASE} < ${ROOT}/website/dump/data.sql
  
  # 'admin' password is 'demo' 
  mysql ${DB_OPT} -D ${DATABASE} -e "UPDATE users SET id = '0' WHERE name = 'system'"
  
  sudo -u www-data sed -e "s/\bpimcore_demo\b/${DB_USER}/g" \
                       -e "s/\bsecretpassword\b/${DB_PASS}/g" \
                       -e "s/\pimcore_demo_pimcore\b/${DATABASE}/g" \
    < ${ROOT}/website/var/config/system.template.php \
    > ${ROOT}/website/var/config/system.php
  
  sudo -u www-data php ${ROOT}/pimcore/cli/console.php reset-password -u admin -p demo
fi

if test "$RELEASE" != "v5"; then
  sudo -u www-data cp /tmp/cache.php ${ROOT}/website/var/config/cache.php
fi

sudo -u www-data touch $INSTALLDIR/.install_complete

# stop temp. mysql service
service mysql stop

while pgrep -o mysqld > /dev/null; do
  # ensure mysql is properly shut down
  sleep 1
done

