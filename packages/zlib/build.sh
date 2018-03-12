#!/bin/bash

ANDROID_PACKAGE_VERSION='1.2.11'
ANDROID_PACKAGE_DIST_LOCATION="http://zlib.net"

ANDROID_PACKAGE_ROOT="$(cd $(dirname "$0") && pwd)"
. "$ANDROID_PACKAGE_ROOT/../common-package.sh"
source_buildenv

cd_src
cmake_install
