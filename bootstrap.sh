#! /usr/bin/env bash

set -e

# set this to TRUE to delete source files when done
SOURCE_DELETE=TRUE

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


# root
BASE_DIR=$(pwd)

# versions to download 
BOOST_VER=1.72.0
OPENSSL_VER=1.1.1d
I2PD_VER=2.29.0

# SHA checksum file names
BOOST_SHA_FILE=""
OPENSSL_SHA_FILE=""
I2P_SHA_FILE=""

### BOOST options to set
# BOOST platforms to build (iOS, tvOS, macOS)
BOOST_PLATFORMS=""
# set Boost platforms needed (1==true, 0==false, if all == 0 then build all)
IOS_BUILD=1
TVOS_BUILD=0
MACOS_BUILD=0

###

### OPENSSL options to set
# Openssl default targets: 
# ios-sim-cross-x86_64 ios64-cross-arm64 ios64-cross-arm64e tvos-sim-cross-x86_64 tvos64-cross-arm64
# to target Catalyst mac-catalyst-x86_64 ( replaces ios-sim-cross-x86_64 ) set this to 1
OPENSSL_CATALYST=0
OPENSSL_TARGETS=""

###

# directories
SCRIPTS_DIR=$BASE_DIR/workspace
CHECKSUM_FUNC=$SCRIPTS_DIR/verify_checksum.sh
BOOST_SRC=$SCRIPTS_DIR/src
BOOST_BUILD_DIR=$SCRIPTS_DIR/build
SSL_DIR=$SCRIPTS_DIR/dist/OpenSSL-for-iPhone

# sigs for source downloads
BOOST_SHA=d73a8da01e8bf8c7eda40b4c84915071a8c8a0df4a6734537ddde4a8580524ee # 1.71.0
OPENSSL_SHA=14cb464efe7ac6b54799b34456bd69558a749a4931ecfd9cf9f71d7881cac7bc # 1.0.2t
# 2.29.0
I2PD_SHA=dfa1c212c217eb2eae40f3f8151d35164c52df630e658dcb261cc9532623377dee376d1c493e8b8bdcae3245ae389e06adf5ef551951d4e139f1626b8432c15b

# change based on version
if [ "${BOOST_VER}" = "1.72.0" ]; then
	BOOST_SHA=59c9b274bc451cf91a9ba1dd2c7fdcaf5d60b1b3aa83f2c9fa143417cc660722 # 1.72.0
fi

if [ "${OPENSSL_VER}" = "1.0.2u" ]; then
	OPENSSL_SHA=ecd0c6ffb493dd06707d38b14bb4d8c2288bb7033735606569d8f90f89669d16 # 1.0.2U
elif [ "${OPENSSL_VER}" = "1.1.1d" ]; then
	OPENSSL_SHA=1e3a91bc1f9dfce01af26026f856e064eab4c8ee0a8f457b5ae30b40b8b711f2 # 1.1.1d
fi


# to stop exporting, use export -n VAR1 VAR2
export BASE_DIR
export BOOST_VER OPENSSL_VER I2PD_VER
export BOOST_SHA OPENSSL_SHA I2PD_SHA

# "include" this file
. $CHECKSUM_FUNC

# set BOOST platforms selected above
if [ $IOS_BUILD -eq 1 ] 
then
	BOOST_PLATFORMS=" -ios"
fi
if [ $TVOS_BUILD -eq 1 ] 
then
	BOOST_PLATFORMS="${BOOST_PLATFORMS} -tvos"
fi
if [ $MACOS_BUILD -eq 1 ] 
then
	BOOST_PLATFORMS="${BOOST_PLATFORMS} -macos"
fi

# set OPENSSL targets if Catalyst wanted
if [ $OPENSSL_CATALYST -eq 1 ]
then
	OPENSSL_TARGETS="--targets=\"mac-catalyst-x86_64 ios64-cross-arm64 ios64-cross-arm64e tvos-sim-cross-x86_64 tvos64-cross-arm64\""
fi


# scripts to run later
BUILD_BOOST="$SCRIPTS_DIR/build-boost.sh $BOOST_PLATFORMS"
BUILD_LIBSSL="$SCRIPTS_DIR/build-libssl.sh $OPENSSL_TARGETS"
BUILD_I2PD=$SCRIPTS_DIR/build-i2pd.sh


# start git
git init

git submodule update --init --recursive

# move to script directory
pushd $BASE_DIR/workspace

# run boost script
$BUILD_BOOST

# copy boost files...
echo "Copying boost .h includes to $BASE_DIR/include\n\n\n"
cp -R "$SCRIPTS_DIR/build/boost/${BOOST_VER}/ios/release/prefix/include/"* "$BASE_DIR/include"

echo "Copying boost .a libs to $BASE_DIR/lib"
cp -R "$SCRIPTS_DIR/build/boost/${BOOST_VER}/ios/release/build/"* "$BASE_DIR/lib"


# run openssl build script
$BUILD_LIBSSL

# copy openssl files...
echo "Copying ssl .h includes to $BASE_DIR/include\n\n\n"
cp -R "$SSL_DIR/include/"* "$BASE_DIR/include"

echo "Copying ssl .a libs to $BASE_DIR/lib"
cp -R "$SSL_DIR/lib/"* "$BASE_DIR/lib"


$BUILD_I2PD

# remove build files

if [ "$SOURCE_DELETE" == "TRUE" ]; then
	echo "Deleting Boost source files..."
	rm -rf "$BOOST_SRC"

	echo "Deleting Boost build files"
	rm -rf "$BOOST_BUILD_DIR"

	echo "Deleting ssl files..."
	echo "build files $SSL_DIR/build/openssl/  ..."
	rm -rf "$SSL_DIR/build/openssl/"*

	echo "tarball $SSL_DIR/dist/  ..."
	rm -rf "$SSL_DIR/dist/"*

	echo "header files $SSL_DIR/include  ...."
	rm -rf "$SSL_DIR/include"*

	echo "builds $SSL_DIR/lib  ..."
	rm -rf "$SSL_DIR/lib"*
fi

popd

MINUTE=60
MINUTES=$((SECONDS / MINUTE)) 
echo "script took ${SECONDS} seconds or ${MINUTES} minutes to execute."
