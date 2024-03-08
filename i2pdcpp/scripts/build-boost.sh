#!/bin/sh
 
set -e

pushd vendor/Apple-Boost-BuildScript

./boost.sh --no-framework \
           -ios \
           --hidden-visibility \
           --boost-version ${BOOST_VER}


mkdir -p ${BUILD_DIR}/iphoneos/lib ${BUILD_DIR}/iphonesimulator/lib ${BUILD_DIR}/iphoneos/include ${BUILD_DIR}/iphonesimulator/include


for lib in build/boost/${BOOST_VER}/ios/release/build/iphonesimulator/x86_64/*.a
do
    name=$(basename $lib)
    libtool -static -o ${BUILD_DIR}/iphonesimulator/lib/${name} build/boost/${BOOST_VER}/ios/release/build/iphonesimulator/x86_64/${name} build/boost/${BOOST_VER}/ios/release/build/iphonesimulator/arm64/${name}
done

cp -rp build/boost/${BOOST_VER}/ios/release/build/iphoneos/arm64/*.a ${BUILD_DIR}/iphoneos/lib
cp -rp build/boost/${BOOST_VER}/ios/release/build/iphoneos/arm64/*.a ${BUILD_DIR}/iphoneos/lib

cp -rp ./build/boost/${BOOST_VER}/ios/release/prefix/include/* ${BUILD_DIR}/iphonesimulator/include/
cp -rp ./build/boost/${BOOST_VER}/ios/release/prefix/include/* ${BUILD_DIR}/iphoneos/include/

# copy asio ssl
cp -rp ./src/boost_*/boost/asio/ssl* ${BUILD_DIR}/iphoneos/include/boost/asio/
cp -rp ./src/boost_*/boost/asio/ssl* ${BUILD_DIR}/iphonesimulator/include/boost/asio/

# copy property_tree
cp -rp ./src/boost_*/boost/property_tree ${BUILD_DIR}/iphoneos/include/boost/
cp -rp ./src/boost_*/boost/property_tree ${BUILD_DIR}/iphonesimulator/include/boost/

# copy multi_index
cp -rp ./src/boost_*/boost/multi_index ${BUILD_DIR}/iphoneos/include/boost/
cp -rp ./src/boost_*/boost/multi_index ${BUILD_DIR}/iphonesimulator/include/boost/

popd
