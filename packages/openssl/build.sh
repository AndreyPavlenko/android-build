#!/bin/bash

ANDROID_PACKAGE_VERSION='1.1.0g'
ANDROID_PACKAGE_DIST_LOCATION="https://www.openssl.org/source"

ANDROID_PACKAGE_ROOT="$(cd $(dirname "$0") && pwd)"
. "$ANDROID_PACKAGE_ROOT/../common-package.sh"

export ANDROID_DEV="$ANDROID_TOOLCHAIN_ROOT"
export CROSS_SYSROOT="$ANDROID_TOOLCHAIN_ROOT/sysroot"

case "$ANDROID_NDK_ARCH" in
  arm64)  target=android64-aarch64;
    ;;
  arm)    target=android; # configure_opts="no-ui no-engine"
    ;;
  x86_64) target=android64;
    ;;
  x86)    target=android-x86;
    ;;
esac

cd_src

OPEN_SSL_DIR="$ANDROID_PACKAGE_INSTALL_DIR"
export CROSS_COMPILE="$CROSS_COMPILE-"
./Configure $target no-dso no-shared no-unit-test $configure_opts --static \
  --prefix="$OPEN_SSL_DIR" --openssldir="$OPEN_SSL_DIR"
make_concurrent depend build_libs
make install_dev
copy_lib_include
