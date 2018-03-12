#!/bin/bash

ANDROID_PACKAGE_VERSION='2.1.8-stable'
ANDROID_PACKAGE_DIST_LOCATION="https://github.com/libevent/libevent/releases/download"
ANDROID_PACKAGE_DIST_URL="$ANDROID_PACKAGE_DIST_LOCATION/release-$ANDROID_PACKAGE_VERSION/libevent-$ANDROID_PACKAGE_VERSION.tar.gz"

ANDROID_PACKAGE_ROOT="$(cd $(dirname "$0") && pwd)"
. "$ANDROID_PACKAGE_ROOT/../common-package.sh"
source_buildenv

cd_src
patch < "$ANDROID_PACKAGE_PATCHES_DIR/arc4random.patch"

if is_api_les 21 || is_arm32; then
    patch < "$ANDROID_PACKAGE_PATCHES_DIR/configure.patch"
    patch < "$ANDROID_PACKAGE_PATCHES_DIR/epollcreate.patch"
elif is_api_les 24; then
    patch < "$ANDROID_PACKAGE_PATCHES_DIR/getifaddrs.patch"
fi

./configure --prefix="/" --host=${CROSS_COMPILE} --with-sysroot="${SYSROOT}" --enable-function-sections --enable-shared=no \
            --disable-openssl --disable-debug-mode --disable-libevent-regress --disable-samples --disable-clock-gettime 
make_concurrent
make_install
copy_lib_include
