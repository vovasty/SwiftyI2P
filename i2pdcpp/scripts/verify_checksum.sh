#!/bin/bash

# =============================================================================
# Author:   David Tonhofer
# Rights:   Public Domain
#
# HISTORY
# -------
#
# 2018-02-18: First version
# 2018-04-02: Merged-in modifications by ChallahuAkbar
# 2019-12-09: Modifications to work on Mac OS without errors
#
# QUALITY CONTROL
# ---------------
#
# This script 100% passes "shellcheck" (https://www.shellcheck.net/) thanks to
# modifications by ChallahuAkbar.
#
# ABOUT
# -----
#
# Make verifying a file's checksum easy! Constanly annoyed by not knowing
# which checksum you have in front of you today and not ready to eyeball
# the result of md5sum? Use this!
#
# SYNOPSIS
# --------
#
#    ...check a checksum against file 'file.tgz':
#
# verify_checksum file.tgz [SHA1, SHA256, MD5 checksum]
#
#    ...or you can exchange the arguments:
#
# verify_checksum [SHA1, SHA256, MD5 checksum] file.tgz
#
#    ...or you can compute all the checksums of a 'file.tgz':
#
# verify_checksum file.tgz
#
#    ...or you can compare two files:
#
# verify_checkusm file1.tgz file2.tgz
#
# UPDATES
# -------
#
# Retrieved from here: https://github.com/dtonhofer/muh_linux_tomfoolery and
# modified to work on Mac OS. Used shasum to compute hashes and removed  
# unnecessary code.
# =============================================================================

set -o nounset

function compare_hash_file {
   local H=$1 # hash passed in
   local F=$2 # file passed in

   local I=0

   declare -a algos
   algos[1]=224
   algos[2]=256
   algos[3]=384
   algos[4]=512
   algos[5]=512224
   algos[6]=512256

   # try all of the algos supported by shasum
   for ALGO in "${algos[@]}"; do
      
      # compute the hash with the current algo
      RESULT=$(shasum -a $ALGO "$F" | cut -f 1 -d ' ')

      if [[ $H == "$RESULT" ]]; then
         echo "true"
         I=1
      fi
   done

   # if there has not been a match then output 'false'
   if [ $I == 0 ]; then
      echo "false"
   fi
}

export -f compare_hash_file
