#!/usr/bin/env bash

set -e

: ${SRC:=`pwd`/dist/i2pd}
: ${IOS_TOOLCHAIN:=`pwd`/dist/ios-cmake/toolchain/iOS.cmake}
: ${IOSBUILDDIR:=`pwd`/build/i2pd}
: ${OUTPUT_DIR_LIB:=`pwd`/lib}
: ${OUTPUT_DIR_HEADERS:=`pwd`/include}

mkdir -p $IOSBUILDDIR
mkdir -p $OUTPUT_DIR_LIB
mkdir -p $OUTPUT_DIR_HEADERS

buildSimulator()
{
    mkdir -p $IOSBUILDDIR/simulator
    pushd $IOSBUILDDIR/simulator > /dev/null
    cmake   -DIOS_PLATFORM=SIMULATOR \
            -DPATCH=/usr/bin/patch \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_TOOLCHAIN_FILE=$IOS_TOOLCHAIN \
            -DWITH_STATIC=yes \
            -DWITH_BINARY=no \
            -DBoost_INCLUDE_DIR=$OUTPUT_DIR_HEADERS \
            -DBoost_LIBRARY_DIR=$OUTPUT_DIR_LIB \
            -DOPENSSL_INCLUDE_DIR=$OUTPUT_DIR_HEADERS \
            -DCMAKE_MIN_IOS=9.0 \
            -DOPENSSL_SSL_LIBRARY=libssl.a \
            -DOPENSSL_CRYPTO_LIBRARY=libcrypto.a \
            $SRC/build >> "$IOSBUILDDIR/simulator.log" 2>&1

    make -j16 VERBOSE=1>> "$IOSBUILDDIR/simulator.log" 2>&1
    popd > /dev/null
}

buildIOS()
{
    mkdir -p $IOSBUILDDIR/ios
    pushd $IOSBUILDDIR/ios > /dev/null
    cmake   -DIOS_PLATFORM=OS \
            -DPATCH=/usr/bin/patch \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_TOOLCHAIN_FILE=$IOS_TOOLCHAIN \
            -DWITH_STATIC=yes \
            -DWITH_BINARY=no \
            -DCMAKE_MIN_IOS=9.0 \
            -DOPENSSL_INCLUDE_DIR=$OUTPUT_DIR_HEADERS \
            -DBoost_INCLUDE_DIR=$OUTPUT_DIR_HEADERS \
            -DBoost_LIBRARY_DIR=$OUTPUT_DIR_LIB \
            -DOPENSSL_SSL_LIBRARY=libssl.a \
            -DOPENSSL_CRYPTO_LIBRARY=libcrypto.a \
            $SRC/build >> "$IOSBUILDDIR/ios.log" 2>&1

    make -j16 VERBOSE=1>> "$IOSBUILDDIR/ios.log" 2>&1
    popd > /dev/null
}

echo building for iOS
buildIOS
echo building for simulator
buildSimulator


libtool -static -o $OUTPUT_DIR_LIB/libi2pdclient.a $IOSBUILDDIR/*/libi2pdclient.a
libtool -static -o $OUTPUT_DIR_LIB/libi2pd.a $IOSBUILDDIR/*/libi2pd.a

rm -rf ${OUTPUT_DIR_HEADERS}/i2pd
mkdir -p ${OUTPUT_DIR_HEADERS}/i2pd
cp ${SRC}/*.h ${OUTPUT_DIR_HEADERS}/i2pd

echo Completed successfully