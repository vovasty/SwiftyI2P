#!/bin/sh
 
set -e

export OPENSSL_VERSION=${OPENSSL_VER}
vendor/OpenSSL/scripts/build.sh
cp -rp vendor/OpenSSL/iphoneos vendor/OpenSSL/iphonesimulator ${BUILD_DIR}/
