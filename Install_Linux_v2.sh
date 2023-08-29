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

DATE_TIME=$(date +%d%m%y_%H%M%S)
echo "Log of WGS Extract installation script executed on: $(date +%c)" >> ${WGSEFIN}/Install_Linux_${DATE_TIME}.log

# Defining function to print an input string to stdout while simultaneously appending it to a log file.
echo_tee () {
    echo "$1" | tee -a ${WGSEFIN}/Install_Linux_${DATE_TIME}.log
}

source ${WGSEFIN}/scripts/Terminal_Linux_v2.sh # Restart in Terminal if not in one

# Make zinstall_common.sh and zcommon.sh aware that they were executed from this installer
export cpuarch="micromamba"

echo_tee ""
echo_tee "\_/"
echo_tee "/_\\"
echo_tee "|_| WGS Extract - Micromamba Installer for Linux (64-bit x86)"
echo_tee "\_/"
echo_tee "/ \\"
echo_tee ""

# Aborts script if script is being run on Linux but *not* on a 64-bit x86 architecture.
# Customised messages for some other architectures are given.
if [[ $(uname -m) != "x86_64" ]]; then
    echo_tee "ERROR: This installation script only works with 64-bit x86 architectures at the moment."
    echo_tee ""
    if [[ $(uname -m) == "arm*" ]] || [[ $(uname -m) == "aarch*" ]]; then
        echo_tee "This systems architecture appears to be ARM-based instead."
    elif [[ $(uname -m) == "i386" ]] || [[ $(uname -m) == "i686" ]]; then
        echo_tee "This systems architecture appears to be 32-bit x86 instead."
    elif [[ $(uname -m) == "ppc*" ]]; then
        echo_tee "This systems architecture appears to be PowerPC-based instead."
    elif [[ $(uname -m) == "s390*" ]]; then
        echo_tee "This systems architecture appears to be IBM S/390-based instead."
    elif [[ -z $(uname -m) ]]; then
        echo_tee "This script was unable to determine the architecture of your system."
    else
        echo_tee "This systems architecture appears to be $(uname -m) instead."
    fi
    echo_tee ""
    echo_tee "Aborting now."
    sleep 2
    echo_tee ""
    exit 1
fi

# Aborts script if C standard library installed on the current distro is musl libc.
if [[ -n $(ldd --version 2>/dev/stdout | head -1 | grep 'musl libc') ]]; then
    echo_tee "ERROR: The musl C standard library is not currently supported by WGS Extract."
    echo_tee ""
    echo_tee "For running glibc executables on your system,"
    echo_tee "please consult your distributions documentation."
    echo_tee ""
    echo_tee "Aborting now."
    sleep 2
    echo_tee ""
    exit 1
fi

if [[ $1 != "restart" ]]; then
    echo_tee "Would you like to run the installer in verbose mode?"
    echo_tee ""
    read -p "Type \"y\" or \"Y\" to run the installer like this or anything else for quiet mode: " VERBOSE_YN
    echo_tee ""

    if [[ ${VERBOSE_YN} == ["y","Y"] ]]; then
        echo_tee "Running in verbose mode."
        echo_tee ""
        export VERBOSE=""
    else
        echo_tee "Running in quiet mode."
        echo_tee ""
        export VERBOSE="-q"
    fi

    if [[ -d ${WGSEFIN}/micromamba/ ]]; then
        echo_tee "WARNING: Files and folders from a previous execution of this script have been detected. Would you like to"
        read -p "delete them to make room for a fresh installation? Type \"y\" or \"Y\" to delete or anything else to keep: " DEL_OLD_YN
        echo_tee ""
        
        if [[ ${DEL_OLD_YN} == ["y","Y"] ]]; then
            echo_tee "Deleting old files and folders."
            rm -rf ${WGSEFIN}/micromamba/
        else
            echo_tee "Keeping old files and folders."
        fi
        
        echo_tee ""
    fi
fi

echo_tee "Downloading portable instance of Micromamba package manager to WGS Extract directory"
echo_tee "and initialising shell environment for running WGS Extract."
echo_tee ""

# TODO: Compile a static micromamba binary and package it in installer. The micromamba-releases binary
# is dymanically linked to glibc so does not work with musl-based distros. Ideally, this micromamba
# environment would wish to run on any Linux distro.
mkdir -p ${WGSEFIN}/micromamba/{bin,cache/pip,jdk8,jdk11}

if [ -f "${WGSEFIN}/micromamba/bin/micromamba" ]; then
    rm -f ${WGSEFIN}/micromamba/bin/micromamba
fi

if command -v curl &>/dev/null; then
    curl -L https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-linux-64 -o ${WGSEFIN}/micromamba/bin/micromamba
elif command -v wget &>/dev/null; then
    wget ${VERBOSE} -O ${WGSEFIN}/micromamba/bin/micromamba https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-linux-64
else
    echo_tee "ERROR: Neither curl or wget appear to be available on \$PATH."
    echo_tee "Please install one of these utilities then run this installer again."
    sleep 2
    echo_tee ""
    exit 1
fi
chmod 755 ${WGSEFIN}/micromamba/bin/micromamba

eval "$(${WGSEFIN}/micromamba/bin/micromamba shell hook -s bash --prefix ${WGSEFIN}/micromamba)"
micromamba activate --prefix ${WGSEFIN}/micromamba
micromamba update -y -a &>/dev/null

echo_tee "Initialisation complete. Within the WGS Extract runtime environment,"
echo_tee "we will install packages required by WGS Extract."
echo_tee ""

# Defining function which aborts script if error during generation of WGS Extract runtime environment occurs.
micromamba_abort () {
    if [[ -n $(grep -P 'numpy\/[core,typing]\/tests' ${WGSEFIN}/Install_Linux_${DATE_TIME}.log | grep -P 'error|critical|problem|aborting') ]]; then
        echo_tee ""
        echo_tee "ERROR: Problem occured with installation of packages within WGS Extract runtime environment."
        echo_tee ""
        echo_tee "Deleting files and folders (except log file) from failed installation attempt and aborting now."
        micromamba deactivate
        rm -rf ${WGSEFIN}/micromamba/
        sleep 2
        echo_tee ""
        exit 1
    fi
}

echo_tee ""
echo_tee "[1/5] Installing basic Unix utilities."
echo_tee ""

micromamba install -y -r ${WGSEFIN}/micromamba -c conda-forge \
sed coreutils zip unzip bash \
grep curl p7zip jq dos2unix ${VERBOSE} | \
tee -a ${WGSEFIN}/Install_Linux_${DATE_TIME}.log

micromamba_abort

echo_tee ""
echo_tee "[2/5] Installing Python base required by WGS Extract."
echo_tee ""

micromamba install -y -r ${WGSEFIN}/micromamba -c conda-forge \
python pip tk ${VERBOSE} | \
tee -a ${WGSEFIN}/Install_Linux_${DATE_TIME}.log

micromamba_abort

echo_tee ""
echo_tee "[3/5] Installing OpenJDK 8 and 11."
echo_tee ""

micromamba deactivate
micromamba activate --prefix ${WGSEFIN}/micromamba/jdk8
micromamba install ${VERBOSE} -y -r ${WGSEFIN}/micromamba/jdk8 -c conda-forge openjdk=8.0.332 | \
tee -a ${WGSEFIN}/Install_Linux_${DATE_TIME}.log
micromamba update -y -a &>/dev/null

micromamba deactivate
micromamba activate --prefix ${WGSEFIN}/micromamba/jdk11
micromamba install ${VERBOSE} -y -r ${WGSEFIN}/micromamba/jdk11 -c conda-forge openjdk=11.0.15 | \
tee -a ${WGSEFIN}/Install_Linux_${DATE_TIME}.log
micromamba update -y -a &>/dev/null

micromamba deactivate
micromamba activate --prefix ${WGSEFIN}/micromamba

micromamba_abort

echo_tee ""
echo_tee "[4/5] Installing bioinformatics tools utilised by WGS Extract."
echo_tee ""

# Bowtie2 omitted due to incompatibility with Python 3.11
# Conda-forge needed to install dependencies of specified packages
micromamba install ${VERBOSE} -y -r ${WGSEFIN}/micromamba -c conda-forge -c bioconda \
bwa bwa-mem2 minimap2 hisat2 \
pbmm2 samtools bcftools tabix fastp | \
tee -a ${WGSEFIN}/Install_Linux_${DATE_TIME}.log

micromamba_abort

if [[ $1 != "restart" ]]; then
    echo_tee "Would you like to delete any caches?"
    echo_tee ""
    read -p "Type \"y\" or \"Y\" to delete caches or anything else to keep: " CACHE_DEL_YN
    echo_tee ""

    if [[ ${CACHE_DEL_YN} == ["y","Y"] ]]; then
        echo_tee "Deleting caches."
        echo_tee ""
        micromamba clean ${VERBOSE} -y -a
        # Deletes useless ~/micromamba/ and ~/.mamba/ folders generated as byproduct of above statement
        if [[ -z $(ls ~/micromamba/ | grep -v 'pkgs') && \
            -z $(ls ~/micromamba/pkgs/ | grep -v 'urls.txt') && \
            ! -s ~/micromamba/pkgs/urls.txt && \
            -z $(ls ~/.mamba/ | grep -v 'pkgs') && \
            -z $(ls ~/.mamba/pkgs/ | grep -v 'urls.txt') && \
            ! -s ~/.mamba/pkgs/urls.txt ]]; then
            rm -rf ~/micromamba/
            rm -rf ~/.mamba/
        fi

        rm -rf ${WGSEFIN}/micromamba/cache/pip/
        echo_tee "Caches deleted."
        echo_tee ""
    else
        echo_tee "Keeping caches."
        echo_tee ""
    fi
fi

# Handling WGS Extract program, Python Library and Java programs via the Common script

echo_tee ""
echo_tee "[5/5] Installing WGS Extract."
echo_tee ""

bash ${WGSEFIN}/scripts/zinstall_common_v2.sh dummy
status=$?

if [[ $status -eq 0 ]]; then
    echo
    echo 'Congratulations!  You finished installing WGS Extract v4 on Linux!'
    echo 'You can start WGS Extract v4 by clicking the WGSExtract.sh file. Make a softlink, rename it to '
    echo 'WGSExtract, and place it on your desktop for ease in starting the program.'
    echo
elif [[ $status -eq 10 ]]; then
    exit  # exit silently as restarted the Install script due to an upgrade
else
    echo
    echo 'Sorry. Appears there was an error during the WGS Extract v4 install on Linux.'
    echo 'Please scroll back through the command log and look for any errors.'
    echo
fi

read -n1 -r -p 'Press any key to close this window (first scroll up to review if desired) ...'
