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
echo "|_| WGS Extract - Micromamba Uninstaller for Linux (64-bit x86)"
echo "\_/"
echo "/ \\"
echo ""
echo ""
echo "Are you sure you want to uninstall WGS Extract from this computer?"
echo ""
read -p "Type \"y\" or \"Y\" to uninstall WGS Extract or anything else to exit: " UNINSTALL_DEL_YN
echo ""

if [[ ${UNINSTALL_DEL_YN} == ["y","Y"] ]]; then
    echo "Uninstalling WGS Extract..."
    rm -f ~/.wgsextract
    find ${WGSEFIN}/ -mindepth 1 -maxdepth 1 -type d -not -name scripts -not -name .git -exec echo rm -rf '{}' \;
    find ${WGSEFIN}/scripts/ -mindepth 1 -maxdepth 1 -type f -not -name Terminal_Linux_v2.sh -not -name zcommon_v2.sh -not -name zinstall_common_v2.sh -exec echo rm -rf '{}' \;
    find ${WGSEFIN}/ -mindepth 1 -maxdepth 1 -type f -not -name Install_Linux_v2.sh -not -name LICENSE -not -name README.md -not -name Run_Linux_v2.sh -not -name Uninstall_Linux_v2.sh -exec echo rm -rf '{}' \;
    echo "WGS Extract has been uninstalled."
    echo ""
fi

echo "Exiting..."
sleep 2
echo ""
