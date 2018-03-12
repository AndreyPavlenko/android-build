#!/bin/bash

ANDROID_PACKAGE_VERSION='1.15'
ANDROID_PACKAGE_DIST_LOCATION="https://ftp.gnu.org/pub/gnu/libiconv"

OPT_DISABLE_STATIC=1
ANDROID_PACKAGE_ROOT="$(cd $(dirname "$0") && pwd)"
. "$ANDROID_PACKAGE_ROOT/../common-package.sh"
source_buildenv

cd_src
./configure -host=$CROSS_COMPILE --with-sysroot="${SYSROOT}" --prefix=/ --enable-static
make_concurrent
make_install
copy_lib_include
