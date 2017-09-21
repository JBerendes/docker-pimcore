FROM google/debian:jessie
MAINTAINER pimcore GmbH <info@pimcore.com>

ADD sources.list /etc/apt/sources.list

RUN apt-get update && \
 DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
 DEBIAN_FRONTEND=noninteractive apt-get -y install wget sudo supervisor pwgen apt-utils 

RUN apt-get -y install apt-transport-https && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ jessie main" > /etc/apt/sources.list.d/php.list && \
    apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
 php7.1-fpm php7.1-cli php7.1-curl php7.1-dev php7.1-gd php7.1-imagick php7.1-imap \
 php7.1-intl php7.1-mcrypt php7.1-memcache php7.1-mysql php7.1-sqlite php7.1-redis \
 php7.1-bz2 php7.1-ldap php7.1-xml php7.1-mbstring php7.1-zip php7.1-bcmath bzip2 unzip memcached ntpdate libxrender1 libfontconfig1 \
 imagemagick inkscape build-essential libssl-dev rcconf sudo lynx autoconf \
 libmagickwand-dev pngnq pngcrush xvfb cabextract libfcgi0ldbl poppler-utils rsync \
 xz-utils libreoffice python-uno libreoffice-math xfonts-75dpi jpegoptim monit \
 aptitude pigz libtext-template-perl mailutils redis-server git-core curl \
 mariadb-server-10.0

# set root password
RUN echo "root:root" | chpasswd

# configure apache
RUN apt-get -y install apache2 libapache2-mod-fastcgi
RUN a2dismod -f cgi autoindex mpm_worker mpm_prefork
RUN a2enmod rewrite actions fastcgi alias status filter expires headers setenvif proxy proxy_fcgi socache_shmcb mpm_event ssl
RUN rm /etc/apache2/sites-enabled/* 

ADD vhost.conf /tmp

# configure mysql
RUN sed -i -e"s/^bind-address\s*=\s*127.1.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
# Make sure to create /var/run/mysqld for the PID file as we don't use the
# debian 'service' command to start MySQL
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld

# configure php-fpm
RUN rm -r /etc/php/7.1/cli/php.ini
RUN rm -r /etc/php/7.1/fpm/php.ini
ADD php.ini /etc/php/7.1/fpm/php.ini 
RUN ln -s /etc/php/7.1/fpm/php.ini /etc/php/7.1/cli/php.ini
RUN mv /etc/php/7.1/fpm/pool.d/www.conf /etc/php/7.1/fpm/pool.d/www.conf.dist 
ADD www-data.conf /tmp

# configure redis
ADD redis.conf /tmp/redis.conf
RUN cat /tmp/redis.conf >> /etc/redis/redis.conf

# install tools
ARG WKHTMLTOPDF_URL=https://downloads.wkhtmltopdf.org/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb
RUN wget $WKHTMLTOPDF_URL -O wkhtmltopdf-0.12.deb && dpkg -i wkhtmltopdf-0.12.deb
ADD install-ghostscript.sh /tmp/install-ghostscript.sh
ADD install-ffmpeg.sh /tmp/install-ffmpeg.sh
RUN chmod 755 /tmp/*.sh
RUN /tmp/install-ghostscript.sh
RUN /tmp/install-ffmpeg.sh 

# setup startup scripts
ADD start-apache.sh /start-apache.sh
ADD start-php-fpm.sh /start-php-fpm.sh
ADD run.sh /run.sh
ADD vars.sh /vars.sh
ADD install.sh /install.sh
RUN chmod 755 /*.sh
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# pimcore config files
ADD cache.php /tmp/cache.php

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ports
EXPOSE 80

ARG PIMCORE_DBNAME
ARG PIMCORE_DBUSER
ARG PIMCORE_DBPASS
ARG PIMCORE_RELEASE
ARG PIMCORE_INSTALLDIR=/pimcore
ARG PIMCORE_PACKAGE_URL

ENV PIMCORE_DBNAME=${PIMCORE_DBNAME}
ENV PIMCORE_DBUSER=${PIMCORE_DBUSER}
ENV PIMCORE_DBPASS=${PIMCORE_DBPASS}
ENV PIMCORE_RELEASE=${PIMCORE_RELEASE}
ENV PIMCORE_INSTALLDIR=${PIMCORE_INSTALLDIR}
ENV PIMCORE_PACKAGE_URL=${PIMCORE_PACKAGE_URL}
ENV PIMCORE_REPO_URL=${PIMCORE_REPO_URL}

CMD ["/run.sh"]
WORKDIR /pimcore
