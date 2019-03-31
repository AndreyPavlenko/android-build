#!/bin/bash

ANDROID_PACKAGE_VERSION='1.2.11'
ANDROID_PACKAGE_DIST_LOCATION="http://zlib.net"

ANDROID_PACKAGE_ROOT="$(cd $(dirname "$0") && pwd)"
. "$ANDROID_PACKAGE_ROOT/../common-package.sh"
source_buildenv

cd_src
cmake_build
$MAKE_COMMAND -j$MAKE_JOBS zlibstatic
mkdir -p "$ANDROID_INSTALL_ROOT/usr/lib"
mkdir -p "$ANDROID_INSTALL_ROOT/usr/include"
cp -v libz.a "$ANDROID_INSTALL_ROOT/usr/lib"
cp -v zconf.h ../zlib.h "$ANDROID_INSTALL_ROOT/usr/include"
