#!/bin/bash

ANDROID_PACKAGE_VERSION='7.66.0'
ANDROID_PACKAGE_DIST_LOCATION="https://curl.haxx.se/download"

ANDROID_PACKAGE_ROOT="$(cd $(dirname "$0") && pwd)"
. "$ANDROID_PACKAGE_ROOT/../common-package.sh"


cd_src
cmake_build -DCMAKE_INSTALL_PREFIX:PATH=/usr -DBUILD_TESTING=false -DBUILD_SHARED_LIBS=false \
            -DCURL_DISABLE_DICT=true -DCURL_DISABLE_DICT=true -DCURL_DISABLE_GOPHER=true \
            -DCURL_DISABLE_IMAP=true -DCURL_DISABLE_POP3=true -DCURL_DISABLE_RTSP=true \
            -DCURL_DISABLE_SMTP=true -DCURL_DISABLE_TELNET=true -DCURL_DISABLE_TFTP=true

make_concurrent all install DESTDIR="$ANDROID_INSTALL_ROOT"
