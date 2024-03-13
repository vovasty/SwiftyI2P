#!/usr/bin/env bash

set -e

I2PD_DL_SRC=https://github.com/PurpleI2P/i2pd/archive/${I2PD_VER}.tar.gz
I2PD_DIR=${BUILD_DIR}/i2pd
I2PD_BUILD_DIR=${I2PD_DIR}/build
I2PD_TARBALL=${I2PD_DIR}/${I2PD_VER}.tar.gz
I2PD_SRC_DIR=${I2PD_DIR}/i2pd-${I2PD_VER}
I2PD_CMAKE_MODULES=${I2PD_SRC_DIR}/build/cmake_modules
I2PD_TARGET_ARCH_CMAKE=TargetArch.cmake

CURL_OPTIONS="-L"

: ${IOS_TOOLCHAIN:=$BASE_DIR/workspace/dist/ios-cmake/ios.toolchain.cmake}
: ${OUTPUT_DIR_LIB:=$BASE_DIR/lib}
: ${OUTPUT_DIR_HEADERS:=$BASE_DIR/include}
: ${BOOST_ROOT:=$BASE_DIR/workspace/build/boost}


mkdir -p ${I2PD_DIR}

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

applyPatch()
{
    patch_file=$1
    OUT="$(patch -p1 --forward -d ${I2PD_SRC_DIR} < ${patch_file})" || echo "${OUT}" | grep "Ignoring previously applied (or reversed) patch" -q || (echo "$OUT" && false);
}

patchI2p()
{
    applyPatch patches/0.daemon_lib.patch
    applyPatch patches/1.2.50.0.2-sim.patch
}

buildNative()
{
    mkdir -p $I2PD_BUILD_DIR/ios
    pushd $I2PD_SRC_DIR/build > /dev/null
    export CXX_FLAGS="$CXX_FLAGS -fvisibility=hidden -fvisibility-inlines-hidden"
    cmake   -DWITH_STATIC=yes \
            -DWITH_BINARY=no \
            -DWITH_DAEMON_LIBRARY=yes \
            -DOPENSSL_INCLUDE_DIR=$OUTPUT_DIR_HEADERS \
            -DBoost_INCLUDE_DIR=${BUILD_DIR}/iphoneos/include \
            -DBoost_LIBRARY_DIR=${BUILD_DIR}/iphoneos/lib \
            -DOPENSSL_SSL_LIBRARY=libssl.a \
            -DOPENSSL_CRYPTO_LIBRARY=libcrypto.a \
            -GXcode \
            -DCMAKE_SYSTEM_NAME=iOS \
            "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" \
            -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
            -DCMAKE_INSTALL_PREFIX=${I2PD_BUILD_DIR}/install \
            -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
            -DCMAKE_IOS_INSTALL_COMBINED=YES


    cmake --build . --config ${BUILD_TYPE} > "buildNative.log" 2>&1
    cmake --install . --config ${BUILD_TYPE} --prefix $(pwd)/install >> "buildNative.log" 2>&1
    popd > /dev/null
}

# download source, verify the download, unpack the tarball
downloadI2p
#verifyI2p "$I2PD_SHA" "$I2PD_TARBALL"
unpackI2p


echo "> $I2PD_SRC_DIR/build"

patchI2p

buildNative

mkdir -p ${BUILD_DIR}/iphonesimulator/include/i2pd ${BUILD_DIR}/iphoneos/include/i2pd

cp ${I2PD_SRC_DIR}/libi2pd/*.h* ${I2PD_SRC_DIR}/libi2pd_client/*.h* ${I2PD_SRC_DIR}/i18n/*.h* ${I2PD_SRC_DIR}/daemon/*.h* ${BUILD_DIR}/iphoneos/include/i2pd
cp ${I2PD_SRC_DIR}/libi2pd/*.h* ${I2PD_SRC_DIR}/libi2pd_client/*.h* ${I2PD_SRC_DIR}/i18n/*.h* ${I2PD_SRC_DIR}/daemon/*.h* ${BUILD_DIR}/iphonesimulator/include/i2pd
cp ${I2PD_SRC_DIR}/build/${BUILD_TYPE}-iphonesimulator/*.a ${BUILD_DIR}/iphonesimulator/lib
cp ${I2PD_SRC_DIR}/build/${BUILD_TYPE}-iphoneos/*.a ${BUILD_DIR}/iphoneos/lib


echo Completed successfully
