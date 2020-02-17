#!/usr/bin/env bash

set -e

I2PD_DL_SRC=https://github.com/PurpleI2P/i2pd/archive/${I2PD_VER}.tar.gz
I2PD_DIR=${BASE_DIR}/i2pd
I2PD_BUILD_DIR=${I2PD_DIR}/build
I2PD_TARBALL=${I2PD_DIR}/${I2PD_VER}.tar.gz
I2PD_SRC_DIR=${I2PD_DIR}/i2pd-${I2PD_VER}
I2PD_CMAKE_MODULES=${I2PD_SRC_DIR}/build/cmake_modules
I2PD_TARGET_ARCH_CMAKE=TargetArch.cmake

CURL_OPTIONS="-L"

: ${IOS_TOOLCHAIN:=$BASE_DIR/ios-cmake/toolchain/ios.toolchain.cmake}
: ${OUTPUT_DIR_LIB:=$BASE_DIR/lib}
: ${OUTPUT_DIR_HEADERS:=$BASE_DIR/include}
: ${BOOST_ROOT:=$BASE_DIR/workspace/build/boost}



downloadI2p()
{
    if [ ! -s "$I2PD_TARBALL" ]; then
        echo "Getting i2p tarball from ${I2PD_DL_SRC}"
        curl ${CURL_OPTIONS} ${I2PD_DL_SRC} > "$I2PD_TARBALL"
    fi
}

unpackI2p()
{
    #echo "Extracting..."
    #cd $BASE_DIR/i2pd ; tar xzf ${I2PD_VER}.tar.gz

    [ -f "$I2PD_TARBALL" ] || abort "Source tarball missing."

    echo Unpacking i2p into "$I2PD_DIR"...

    [ -d "$I2PD_DIR" ]    || mkdir -p "$I2PD_DIR"
    [ -d "$I2PD_SRC_DIR" ] || ( cd "$I2PD_DIR"; tar xzf "$I2PD_TARBALL" )
    [ -d "$I2PD_SRC_DIR" ] && echo "    ...unpacked as $I2PD_SRC_DIR"
    
}

verifyI2p()
{
    local HASH=$1
    local FILE=$2

    echo "Verifying i2p ${FILE}..."

    # compare hash to file and capture return value
    local res=$(compare_hash_file "$HASH" "$FILE")

    echo "If this hash is matches, 'true' should print: ${res}"

    if [ $res == false ]; then
        echo "i2p tarball failed signature check"
        exit 1
    fi

}

buildSimulator()
{
    mkdir -p $I2PD_BUILD_DIR/simulator
    pushd $I2PD_SRC_DIR/build > /dev/null
    cmake   -DPLATFORM=SIMULATOR64 \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_TOOLCHAIN_FILE=$IOS_TOOLCHAIN \
            -DWITH_STATIC=yes \
            -DWITH_BINARY=no \
            -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=$I2PD_BUILD_DIR/simulator \
            -DBoost_INCLUDE_DIR=$BOOST_ROOT/${BOOST_VER}/ios/release/prefix/include \
            -DBoost_LIBRARY_DIR=$BOOST_ROOT/${BOOST_VER}/ios/release/prefix/lib \
            -DOPENSSL_INCLUDE_DIR=$OUTPUT_DIR_HEADERS \
            -DDEPLOYMENT_TARGET=11.0 \
            -DOPENSSL_SSL_LIBRARY=libssl.a \
            -DOPENSSL_CRYPTO_LIBRARY=libcrypto.a \
            $I2PD_SRC_DIR/build >> "$I2PD_BUILD_DIR/simulator.log" 2>&1

    make -j16 VERBOSE=1>> "$I2PD_BUILD_DIR/simulator.log" 2>&1
    popd > /dev/null
}

buildIOS()
{
    mkdir -p $I2PD_BUILD_DIR/ios
    pushd $I2PD_SRC_DIR/build > /dev/null
    echo "`pwd`"
    cmake   -DPLATFORM=OS64 \
            -DPATCH=/usr/bin/patch \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_TOOLCHAIN_FILE=$IOS_TOOLCHAIN \
            -DWITH_STATIC=yes \
            -DWITH_BINARY=no \
            -DDEPLOYMENT_TARGET=11.0 \
            -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=$I2PD_BUILD_DIR/ios \
            -DOPENSSL_INCLUDE_DIR=$OUTPUT_DIR_HEADERS \
            -DBoost_INCLUDE_DIR=$BOOST_ROOT/${BOOST_VER}/ios/release/prefix/include \
            -DBoost_LIBRARY_DIR=$BOOST_ROOT/${BOOST_VER}/ios/release/prefix/lib \
            -DOPENSSL_SSL_LIBRARY=libssl.a \
            -DOPENSSL_CRYPTO_LIBRARY=libcrypto.a \

    make -j16 VERBOSE=1>> "$I2PD_BUILD_DIR/ios.log" 2>&1
    popd > /dev/null
}

# download source, verify the download, unpack the tarball
downloadI2p
verifyI2p "$I2PD_SHA" "$I2PD_TARBALL"
unpackI2p

# copy customized TargetArch.cmake for i2p on iOS
cp -f ${BASE_DIR}/workspace/${I2PD_TARGET_ARCH_CMAKE} ${I2PD_CMAKE_MODULES}/${I2PD_TARGET_ARCH_CMAKE}


echo building for iOS
echo "> $I2PD_SRC_DIR/build"
buildIOS


echo building for simulator
buildSimulator

# rename files to avoid "same member name" problem
# https://groups.google.com/a/chromium.org/forum/#!topic/gn-dev/bbOBxxheLgc
# it appears the name change needs to occur with the source files, not the *.a files :(
# https://issues.apache.org/jira/browse/ARROW-7604
# the upside is that this appears to be a warning, not an error. it appears...
mv $I2PD_BUILD_DIR/simulator/libi2pdclient.a $I2PD_BUILD_DIR/simulator/libi2pdclient-sim.a
mv $I2PD_BUILD_DIR/simulator/libi2pd.a $I2PD_BUILD_DIR/simulator/libi2pd-sim.a

libtool -static -o $OUTPUT_DIR_LIB/libi2pdclient.a $I2PD_BUILD_DIR/*/libi2pdclient*.a
libtool -static -o $OUTPUT_DIR_LIB/libi2pd.a $I2PD_BUILD_DIR/*/libi2pd*.a

#rm -rf ${OUTPUT_DIR_HEADERS}/i2pd
mkdir -p ${OUTPUT_DIR_HEADERS}/i2pd
cp -f ${I2PD_SRC_DIR}/*/*.h ${OUTPUT_DIR_HEADERS}/i2pd
cp -f ${I2PD_SRC_DIR}/*/*.hpp ${OUTPUT_DIR_HEADERS}/i2pd

echo Completed successfully