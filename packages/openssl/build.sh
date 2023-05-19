#!/bin/bash

ANDROID_PACKAGE_VERSION='1.1.1h'
ANDROID_PACKAGE_DIST_LOCATION="https://www.openssl.org/source"

ANDROID_PACKAGE_ROOT="$(cd $(dirname "$0") && pwd)"
. "$ANDROID_PACKAGE_ROOT/../common-package.sh"

case "$ANDROID_NDK_ARCH" in
  arm64)
    export OPENSSL_ANDROID_ABI=android-arm64
    ;;
  arm)
    export OPENSSL_ANDROID_ABI=android-arm
    ;;
  x86_64)
    export OPENSSL_ANDROID_ABI=android-x86_64
    ;;
  x86)
    export OPENSSL_ANDROID_ABI=android-x86
    ;;
esac

OPENSSL_CONFIGURE_OPTS="--prefix=/usr no-shared  no-idea no-camellia no-seed no-bf no-cast no-rc2 no-md2 no-md4 no-mdc2 no-dsa no-err no-engine no-tests no-unit-test no-external-tests no-dso no-dynamic-engine no-stdio zlib"

echo "OPENSSL_ANDROID_ABI=$OPENSSL_ANDROID_ABI"

export ANDROID_NDK="$ANDROID_TOOLCHAIN_ROOT"
export ANDROID_NDK_HOME="$ANDROID_NDK"
export PATH="$ANDROID_TOOLCHAIN_ROOT/bin:$PATH"

cd_src
./Configure ${OPENSSL_CONFIGURE_OPTS} ${OPENSSL_ANDROID_ABI} -D__ANDROID_API__=${ANDROID_NDK_API}

make_concurrent
$MAKE_COMMAND install_dev DESTDIR="$ANDROID_INSTALL_ROOT"
