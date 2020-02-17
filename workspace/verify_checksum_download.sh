#!/bin/bash

# =============================================================================
# Author:   Dexmar
# Rights:   Public Domain
#
# HISTORY
# -------
#
# 2020-02-08: First version
#
# QUALITY CONTROL
# ---------------
#
# 
#
# ABOUT
# -----
#
# Download SHA checksum file and verify against downloaded file
#
# SYNOPSIS
# --------
#
#    TODO ...
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
