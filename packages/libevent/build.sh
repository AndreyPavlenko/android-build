#!/bin/bash

ANDROID_PACKAGE_VERSION='2.1.11-stable'
ANDROID_PACKAGE_DIST_LOCATION="https://github.com/libevent/libevent/releases/download"
ANDROID_PACKAGE_DIST_URL="$ANDROID_PACKAGE_DIST_LOCATION/release-$ANDROID_PACKAGE_VERSION/libevent-$ANDROID_PACKAGE_VERSION.tar.gz"

ANDROID_PACKAGE_ROOT="$(cd $(dirname "$0") && pwd)"
. "$ANDROID_PACKAGE_ROOT/../common-package.sh"

cd_src

patch -p1 < "$ANDROID_PACKAGE_PATCHES_DIR/7201062.patch"

cmake_build -DEVENT__LIBRARY_TYPE=STATIC -DEVENT__DISABLE_BENCHMARK=true -DEVENT__DISABLE_TESTS=true \
            -DEVENT__DISABLE_REGRESS=true -DEVENT__DISABLE_SAMPLES=true
make_concurrent all install DESTDIR="$ANDROID_INSTALL_ROOT"
