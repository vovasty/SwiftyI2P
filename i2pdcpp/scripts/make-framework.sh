#!/usr/bin/env bash

set -e

libtool -static -o ${BUILD_DIR}/iphoneos.a ${BUILD_DIR}/iphoneos/lib/*.a
libtool -static -o ${BUILD_DIR}/iphonesimulator.a ${BUILD_DIR}/iphonesimulator/lib/*.a

xcrun xcodebuild -create-xcframework \
    -output ${INSTALL_DIR}/i2pdcpp.xcframework \
    -library ${BUILD_DIR}/iphoneos.a \
    -headers ${BUILD_DIR}/iphoneos/include \
    -library ${BUILD_DIR}/iphonesimulator.a \
    -headers ${BUILD_DIR}/iphonesimulator/include

