#!/bin/bash
set -e

: ${ANDROID_DEV_ROOT:="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"}
: ${ANDROID_NDK_API:='21'}
: ${ANDROID_NDK_ARCH:='arm64'} # 'arm', 'arm64', 'x86', 'x86_64'
: ${ANDROID_NDK_STL:='libc++'}

: ${ANDROID_ROOT:="$HOME/android"}
: ${ANDROID_NDK_ROOT:="$ANDROID_ROOT/android-ndk"}
: ${ANDROID_TOOLCHAIN_ROOT:="$ANDROID_DEV_ROOT/toolchain/$ANDROID_NDK_ARCH-api$ANDROID_NDK_API-$ANDROID_NDK_STL"}
: ${ANDROID_BUILD_ROOT:="$ANDROID_DEV_ROOT/build/$ANDROID_NDK_ARCH-api$ANDROID_NDK_API"}
: ${ANDROID_INSTALL_ROOT:="$ANDROID_DEV_ROOT/install/$ANDROID_NDK_ARCH-api$ANDROID_NDK_API"}
: ${ANDROID_DOWNLOADS_DIR:="$ANDROID_DEV_ROOT/downloads"}

: ${MAKE_COMMAND:='make'}
: ${CMAKE_COMMAND:=$ANDROID_TOOLCHAIN_ROOT/bin/cmake}

function is_arm32() {
  [ "$ANDROID_NDK_ARCH" = 'arm' ]
}

function is_arm64() {
  [ "$ANDROID_NDK_ARCH" = 'arm64' ]
}

function is_arm() {
  is_arm64 || is_arm32
}

function is_api_les() {
  [ "$ANDROID_NDK_API" -lt "$1" ]
}

case "$ANDROID_NDK_ARCH" in
  arm64)  
    export ANDROID_ABI=arm64-v8a
    export CROSS_COMPILE=aarch64-linux-android
    ;;
  arm)
    export ANDROID_ABI=armeabi-v7a
    export CROSS_COMPILE=arm-linux-androideabi
    ;;
  x86_64)
    export ANDROID_ABI=x86_64
    export CROSS_COMPILE=x86_64-linux-android
    ;;
  x86)
    export ANDROID_ABI=x86
    export CROSS_COMPILE=i686-linux-android
    ;;
esac

if ! which cmake > /dev/null; then
  echo "cmake not found!"
  exit 1
fi

if [ ! -e "$ANDROID_TOOLCHAIN_ROOT" ]; then
  echo "Creating the Android Standalone NDK: $ANDROID_TOOLCHAIN_ROOT"
  $ANDROID_NDK_ROOT/build/tools/make_standalone_toolchain.py \
    --arch=$ANDROID_NDK_ARCH --api=$ANDROID_NDK_API \
    "--install-dir=$ANDROID_TOOLCHAIN_ROOT" --stl=$ANDROID_NDK_STL

  # Add ANDROID_API version directly to gcc executable
  mv "$ANDROID_TOOLCHAIN_ROOT/bin/$CROSS_COMPILE-gcc" "$ANDROID_TOOLCHAIN_ROOT/bin/$CROSS_COMPILE-gcc-orig"
  sed -e "s/#NAME#/$CROSS_COMPILE-gcc-orig/; s/#ARGS#/-D__ANDROID_API__=$ANDROID_NDK_API/g"\
    < "$ANDROID_DEV_ROOT/templates/exec_template.sh" > "$ANDROID_TOOLCHAIN_ROOT/bin/$CROSS_COMPILE-gcc"
  chmod 775 "$ANDROID_TOOLCHAIN_ROOT/bin/$CROSS_COMPILE-gcc"

  # Create a cmake wrapper
  CMAKE="$(which cmake)"
  CMAKE="$CMAKE -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake"
  CMAKE="$CMAKE -DANDROID_STL=c++_static"
  CMAKE="$CMAKE -DANDROID_ABI=$ANDROID_ABI"
  CMAKE="$CMAKE -DANDROID_PLATFORM=android-$ANDROID_NDK_API"
  CMAKE="$CMAKE -DCMAKE_INSTALL_PREFIX=$ANDROID_INSTALL_ROOT"
  CMAKE="$CMAKE -DCMAKE_FIND_ROOT_PATH=$ANDROID_INSTALL_ROOT"
  CMAKE="$CMAKE -DCMAKE_INCLUDE_PATH=$ANDROID_INSTALL_ROOT/include"
  CMAKE="$CMAKE -DCMAKE_INSTALL_PREFIX:PATH="
  CMAKE="$CMAKE -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=true"
  CMAKE="$CMAKE -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=true"
  CMAKE="$CMAKE -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=true"
  CMAKE="$CMAKE -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=true"
  CMAKE="$CMAKE -DCMAKE_CROSSCOMPILING=true"
  CMAKE="$CMAKE -DCMAKE_BUILD_TYPE=RELEASE"
  echo '#!/bin/sh' > "$CMAKE_COMMAND"
  echo "exec $CMAKE" '"$@"' >> "$CMAKE_COMMAND"
  chmod 755 "$ANDROID_TOOLCHAIN_ROOT/bin/cmake"
fi

export PATH="$ANDROID_TOOLCHAIN_ROOT/bin:$PATH"
mkdir -p "$ANDROID_BUILD_ROOT" "$ANDROID_INSTALL_ROOT" "$ANDROID_DOWNLOADS_DIR"

[ -f "$HOME/.proxy" ] && . "$HOME/.proxy" || true
