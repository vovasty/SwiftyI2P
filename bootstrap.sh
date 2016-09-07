#! /usr/bin/env bash

set -e

BASEDIR=$(pwd)/$(dirname $0)
SCRIPTSDIR=$BASEDIR/lib
BUILD_BOOST=$SCRIPTSDIR/build-boost.sh
BUILD_LIBSSL=$SCRIPTSDIR/build-libssl.sh
BUILD_I2PD=$SCRIPTSDIR/build-i2pd.sh

git submodule update --init --recursive

pushd $BASEDIR/lib
$BUILD_BOOST
$BUILD_LIBSSL
$BUILD_I2PD
popd
