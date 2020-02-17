#!/bin/sh
 
set -e

cd dist/OpenSSL-for-iPhone
./build-libssl.sh

#cp lib/*.a ../../lib
#cp -r include/openssl ../../include