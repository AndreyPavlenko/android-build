#!/bin/bash

: ${ANDROID_DEV_ROOT:="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"}
. "$ANDROID_DEV_ROOT/common.sh"

if [ -z "$OPT_DISABLE_STATIC" ]; then
	CFLAGS="$CFLAGS -static"
	LDFLAGS="$LDFLAGS -static"
fi

if [ -z "$OPT_DISABLE_FPIC" ]; then
  CFLAGS="$CFLAGS -fPIC"
  LDFLAGS="$LDFLAGS -fPIC"
fi

if [ -z "$OPT_DISABLE_LD_GOLD" ]; then
	export LD=$CROSS_COMPILE-ld.gold
	# CFLAGS="$CFLAGS -fuse-ld=gold"
else
	export LD=$CROSS_COMPILE-ld
fi

export CPP=$CROSS_COMPILE-cpp
export AR=$CROSS_COMPILE-ar
export AS=$CROSS_COMPILE-as
export NM=$CROSS_COMPILE-nm
export CC=$CROSS_COMPILE-clang
export CXX=$CROSS_COMPILE-clang++
export LD=$CROSS_COMPILE-ld.gold
export RANLIB=$CROSS_COMPILE-ranlib
export NM=${CROSS_COMPILE}-nm

export SYSROOT="$ANDROID_TOOLCHAIN_ROOT/sysroot"
export PKG_CONFIG_PATH=$ANDROID_INSTALL_ROOT/lib/pkgconfig

CFLAGS="$CFLAGS --sysroot=$SYSROOT -I$SYSROOT/usr/include -I$ANDROID_TOOLCHAIN_ROOT/include -I$ANDROID_INSTALL_ROOT/include"
export CFLAGS="$CFLAGS -O3 -DNDEBUG -D__ANDROID_API__=$ANDROID_NDK_API -flto"
export CPPFLAGS="$CFLAGS"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="$LDFLAGS -flto -Wl,--gc-sections -Wl,--strip-all -L$SYSROOT/usr/lib -L$ANDROID_TOOLCHAIN_ROOT/lib -L$ANDROID_INSTALL_ROOT/lib"
