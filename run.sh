#!/bin/bash

set -xeuo pipefail

. /vars.sh

# install pimcore if needed
if [ ! -e $INSTALLDIR/.install_complete ]; then
  . /install.sh
fi

exec supervisord -n
