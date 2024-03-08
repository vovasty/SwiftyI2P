#! /usr/bin/env bash

set -e

# set this to TRUE to delete source files when done
SOURCE_DELETE=FALSE

# =============================================================================
#
# ABOUT
# -----
# 
# To build i2p for use in Swift project!
#
# REQUIREMENTS
# ------------
#
# Cmake and command line tools are necessary for build, Homebrew is not. If already
# have a Cmake then Homebrew may not be required. Homebrew is only to install Cmake.
#
# * Xcode command line tools (CLT) xcode-select --install (or let Homebrew install)
# * Homebrew ( https://brew.sh/ )
# * cmake  brew install cmake  OR  brew cask install cmake ( if you want cmake gui also )
# * make sure path is set to Xcode: xcode-select -print-path ( if set to command line tools then problems )
# ** to set path to xcode do something like: sudo xcode-select -switch /<path to xcode>/Xcode.app
#
# HISTORY
# -------
#
# 2019-12-19: First version with Boost 1.71.0, Openssl 1.0.2t, i2pd 2.29.0
# 2020-01-29: Update to Boost 1.72.0, Openssl 1.0.2u
# 2020-02-01: Allow for selection of platforms to build Boost (ios, tvos, macos), DEFAULT: all
# 2020-02-11: Update to Openssl 1.1.1d. Give user option to set Boost Platforms and Openssl targets
#
# LOCATION
# --------
#
# Originally available at https://github.com/vovasty/SwiftyI2P
#
# TESTING
# -------
#
# Built on Mac Cataline 10.15.2 with Xcode 11.2.1 and Cmake 3.16.1
#
# =============================================================================


# versions to download
BOOST_VER=1.84.0
I2PD_VER=2.50.2
OPENSSL_VER=3.2.1
#BUILD_TYPE=Debug
BUILD_TYPE=Release

# root
BASE_DIR=$(pwd)

# SHA checksum file names
I2P_SHA_FILE=""

###

# directories
SCRIPTS_DIR=$BASE_DIR/scripts
CHECKSUM_FUNC=$SCRIPTS_DIR/verify_checksum.sh
BOOST_SRC=$SCRIPTS_DIR/src
BOOST_BUILD_DIR=$SCRIPTS_DIR/build
INSTALL_DIR=${BASE_DIR}/install
BUILD_DIR=${BASE_DIR}/build

# 2.29.0
I2PD_SHA=dfa1c212c217eb2eae40f3f8151d35164c52df630e658dcb261cc9532623377dee376d1c493e8b8bdcae3245ae389e06adf5ef551951d4e139f1626b8432c15b


# to stop exporting, use export -n VAR1 VAR2
export BASE_DIR INSTALL_DIR BUILD_DIR BUILD_TYPE
export BOOST_VER OPENSSL_VER I2PD_VER
export I2PD_SHA

# scripts to run later
BUILD_BOOST="$SCRIPTS_DIR/build-boost.sh --boost-version ${BOOST_VER}"
BUILD_LIBSSL="$SCRIPTS_DIR/build-libssl.sh"
BUILD_I2PD=$SCRIPTS_DIR/build-i2pd.sh

mkdir -p ${INSTALL_DIR} ${BUILD_DIR}

# start git
git submodule update --init --recursive

# move to script directory

export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH:+${CPLUS_INCLUDE_PATH}:}${INSTALL_DIR}/iphonesimulator/include:${INSTALL_DIR}/iphoneos/include"
export LIBRARY_PATH="${LIBRARY_PATH:+${LIBRARY_PATH}:}${INSTALL_DIR}/iphonesimulator/lib:${INSTALL_DIR}/iphoneos/lib"


$BUILD_LIBSSL

$BUILD_BOOST

$BUILD_I2PD

$SCRIPTS_DIR/make-framework.sh


MINUTE=60
MINUTES=$((SECONDS / MINUTE))
echo "script took ${SECONDS} seconds or ${MINUTES} minutes to execute."
