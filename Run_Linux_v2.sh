#!/usr/bin/env bash
#
# WGS Extract Install Script for Linux x86_64
# Copyright (C) 2020-22 Randolph Harr
#
# License: GNU General Public License v3 or later
# A copy of GNU GPL v3 should have been included in this software package in LICENSE.txt.

# Make sure we are in the installation directory (and leave the variable there to find it again) ...
WGSEDIR=$(dirname "$0")             # Get the script location to determine install directory
WGSEABS=$(cd "$WGSEDIR"; pwd)       # By cd'ing to it, resolve any aliases and symlinks
export WGSEFIN="${WGSEABS}"                # Removed escape any embedded spaces; add trailing slash ${WGSEABS/ /\\ }/
cd "${WGSEFIN}"
# echo '******** WGSEFIN:' "${WGSEFIN}"

source ${WGSEFIN}/scripts/Terminal_Linux_v2.sh # Restart in Terminal if not in one

echo ""
echo "\_/"
echo "/_\\"
echo "|_| WGS Extract - Micromamba Installer for Linux (64-bit x86)"
echo "\_/"
echo "/ \\"
echo ""

if [[ ! -d ${WGSEFIN}/micromamba/ ]]; then
    echo "ERROR: It appears you haven't installed WGS Extract via the \"install.sh\" script."
    echo "Please install WGS Extract via this method then run this script."
    echo ""
    echo "Aborting..."
        sleep 2
    echo ""
    exit 1
    
fi

eval "$(${WGSEFIN}/micromamba/bin/micromamba shell hook -s bash --prefix ${WGSEFIN}/micromamba)"
micromamba activate --prefix ${WGSEFIN}/micromamba

python ${WGSEFIN}/program/wgsextract.py
