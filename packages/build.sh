#!/bin/bash
set -e

: ${ANDROID_PACKAGES_ROOT:="$(cd $(dirname "$0") && pwd)"}
: ${CONFIGS:='arm:16 arm:21 arm64:21 x86:16 x86_64:21'}
: ${PACKAGES:='zlib openssl curl libevent transmission'}
export ANDROID_PACKAGES_ROOT

function build_packages() {
  for i in "$@"; do
    echo "Building package $i"
    cd "$ANDROID_PACKAGES_ROOT/$i"
    ./build.sh
  done
}

echo "Building packages: $PACKAGES"

for c in $CONFIGS; do
  export ANDROID_NDK_API="${c#*:}"
  export ANDROID_NDK_ARCH="${c%:*}"
  echo "ANDROID_NDK_API=$ANDROID_NDK_API, ANDROID_NDK_ARCH=$ANDROID_NDK_ARCH"
  build_packages $PACKAGES
done
