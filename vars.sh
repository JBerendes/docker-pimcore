set -xeuo pipefail

INSTALLDIR=${PIMCORE_INSTALLDIR:-/pimcore}
DATABASE=${PIMCORE_DBNAME:-pimcore}
DB_USER=${PIMCORE_DBUSER:-pimcore}
DB_PASS=${PIMCORE_DBPASS}
RELEASE=${PIMCORE_RELEASE:-demo}

test $RELEASE = v5 && ROOT=$INSTALLDIR/web

DB_OPT="-u ${DB_USER}"

if test -z $DB_PASS; then
  DB_OPT="${DB_OPT}"
else
  DB_OPT="${DB_OPT} -p${DB_PASS}"
fi

if test $RELEASE = demo; then
  URI=/download/pimcore-unstable.zip
elif test $RELEASE = "v5"; then
  URI=/download-5/pimcore-unstable.zip
else
  URI=/download/pimcore-stable.zip
fi
