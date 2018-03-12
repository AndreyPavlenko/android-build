#!/bin/bash

ANDROID_PACKAGE_VERSION='7.59.0'
ANDROID_PACKAGE_DIST_LOCATION="https://curl.haxx.se/download"

ANDROID_PACKAGE_ROOT="$(cd $(dirname "$0") && pwd)"
. "$ANDROID_PACKAGE_ROOT/../common-package.sh"
source_buildenv

cd_src
./configure --prefix=/ --host=${CROSS_COMPILE} --with-ssl --with-zlib --disable-gopher --disable-shared --enable-static \
            --disable-imap --disable-ldap --disable-ldaps --disable-pop3 --disable-rtsp --disable-smtp --enable-proxy \
            --disable-telnet --disable-tftp --without-gnutls --without-libidn --without-librtmp --disable-dict
make_concurrent
make_install
copy_lib_include
