#!/bin/bash

: ${ANDROID_PACKAGE_ROOT:="$(cd $(dirname "$0") && pwd)"}
: ${ANDROID_PACKAGE_NAME:="$(basename "$ANDROID_PACKAGE_ROOT")"}
: ${ANDROID_PACKAGES_ROOT:="$(dirname "$ANDROID_PACKAGE_ROOT")"}
: ${ANDROID_DEV_ROOT:="$(dirname "$ANDROID_PACKAGES_ROOT")"}
. "$ANDROID_DEV_ROOT/common.sh"

: ${ANDROID_PACKAGE_DIST_EXT:='tar.gz'}
: ${ANDROID_PACKAGE_DIST_NAME:="$ANDROID_PACKAGE_NAME-$ANDROID_PACKAGE_VERSION.$ANDROID_PACKAGE_DIST_EXT"}
: ${ANDROID_PACKAGE_DIST_PATH:="$ANDROID_DOWNLOADS_DIR/$ANDROID_PACKAGE_DIST_NAME"}
: ${ANDROID_PACKAGE_DIST_URL:="$ANDROID_PACKAGE_DIST_LOCATION/$ANDROID_PACKAGE_DIST_NAME"}
: ${ANDROID_PACKAGE_SRC_DIR:="$ANDROID_BUILD_ROOT/$ANDROID_PACKAGE_NAME/src"}
: ${ANDROID_PACKAGE_INSTALL_DIR:="$ANDROID_BUILD_ROOT/$ANDROID_PACKAGE_NAME/install"}
: ${ANDROID_PACKAGE_PATCHES_DIR:="$ANDROID_PACKAGE_ROOT/patches"}

function fail() {
  echo "$*"
  exit 1
}

function source_buildenv() {
  . "$ANDROID_DEV_ROOT/common-build-env.sh"
}

function require_var() {
  for i in "$@"; do
    [ ! -v "$i" ] && fail "Environment variable $i is not set" || true
  done
}

function download_dist() {
  require_var ANDROID_PACKAGE_DIST_PATH ANDROID_DOWNLOADS_DIR ANDROID_PACKAGE_DIST_URL
  if [ ! -f "$ANDROID_PACKAGE_DIST_PATH" ]; then
    mkdir -p "$ANDROID_DOWNLOADS_DIR"
    if ! wget -O "$ANDROID_PACKAGE_DIST_PATH" "$ANDROID_PACKAGE_DIST_URL"; then
      rm -f "$ANDROID_PACKAGE_DIST_PATH"
      fail "Failed to download $ANDROID_PACKAGE_DIST_URL"
    fi
  fi
}

function extract_dist() {
  require_var ANDROID_PACKAGE_DIST_PATH
  download_dist
  rm -rf "$ANDROID_PACKAGE_SRC_DIR"
  mkdir -p "$ANDROID_PACKAGE_SRC_DIR"

  case "$ANDROID_PACKAGE_DIST_PATH" in
  *.tar.gz) tar -C "$ANDROID_PACKAGE_SRC_DIR" --strip-components=1 -xzf "$ANDROID_PACKAGE_DIST_PATH"
            ;;
  *.tar.xz) tar -C "$ANDROID_PACKAGE_SRC_DIR" --strip-components=1 -xJf "$ANDROID_PACKAGE_DIST_PATH"
            ;;
  *.tar.bz2) tar -C "$ANDROID_PACKAGE_SRC_DIR" --strip-components=1 -xjf "$ANDROID_PACKAGE_DIST_PATH"
            ;;
  *) fail "Unsupported distrib archive: $ANDROID_PACKAGE_DIST_PATH"
            ;;
  esac
}

function cd_src() {
  extract_dist
  cd "$ANDROID_PACKAGE_SRC_DIR"
}

function make_concurrent() {
  $MAKE_COMMAND -j$MAKE_JOBS "$@"
}

function make_install() {
  rm -rf "$ANDROID_PACKAGE_INSTALL_DIR"
  mkdir -p "$ANDROID_PACKAGE_INSTALL_DIR"
  $MAKE_COMMAND install DESTDIR="$ANDROID_PACKAGE_INSTALL_DIR" "$@"
}

function copy_install() {
  for i in "$@"; do
    cp -rv "$ANDROID_PACKAGE_INSTALL_DIR/$i" "$ANDROID_INSTALL_ROOT"
  done
}

function copy_lib_include() {
  copy_install lib include
}

function cmake_build() {
  rm -rf build
  mkdir build
  cd build
  echo $CMAKE_COMMAND "$@" ..
  $CMAKE_COMMAND "$@" ..
}

function cmake_install() {
  cmake_build
  make_concurrent
  $MAKE_COMMAND install DESTDIR="$ANDROID_INSTALL_ROOT"
}

function dir_checksum() {
  find "$1" -type f -print | sort | xargs cat | sha1sum | cut -d' ' -f1
}
