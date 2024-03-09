#!/bin/sh
 
set -e

export OPENSSL_VERSION=${OPENSSL_VER}
pushd vendor/OpenSSL
scripts/build.sh
cp -rp iphoneos iphonesimulator ${BUILD_DIR}/
popd

