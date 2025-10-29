#!/bin/bash

###############################################################################
# Copyright (C) 2025 Advanced Micro Devices, Inc. All Rights Reserved.
# SPDX-License-Identifier: MIT
###############################################################################

#
# This script is used to setup the development environment for the EDF Yocto project.
#

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;95m'
RESET='\033[0m'

RELEASE="2025.2"
BASE_DIR=$(pwd)
SDTGEN_OUT_DIR="$1"
SKIP_BOOTBIN="$2"

REPO_BIN=""
EDF_YOCTO_DIR="$BASE_DIR/yocto/edf"

# Download Repo Tools
curl -fSL https://storage.googleapis.com/git-repo-downloads/repo -o repo
if [ $? -ne 0 ]; then
	echo -e "[Error] ${RED}Failed to download repo tool.${RESET}"
	exit 1
fi

# Set Repo binary in Environment
chmod a+x repo
mkdir -p repo_bin
mv repo repo_bin/
REPO_BIN=$(pwd)/repo_bin/repo
export PATH="$PATH:$(pwd)/repo_bin"
echo -e "[Info] ${CYAN}Repo tool available: $REPO_BIN${RESET}"

# Install Repo binary
mkdir -p "$EDF_YOCTO_DIR"
cd "$EDF_YOCTO_DIR"
if [ ! -x $REPO_BIN ]; then
	echo -e "[Error] ${RED}repo tool not found or not executable.${RESET}"
	exit 1
fi
"$REPO_BIN" init -u https://gitenterprise.xilinx.com/Yocto/yocto-manifests.git -b $RELEASE -m default-edf-internal.xml

# Set Development environment in repo
"$REPO_BIN" sync
timestamp=$(date +"%Y%m%d%H%M%S")
branchname="xc2ve3858-$timestamp"
"$REPO_BIN" start "$branchname" --all

# Launch EDF Yocto build
cd "$BASE_DIR"
./bitbake-build.sh "$EDF_YOCTO_DIR" "$SDTGEN_OUT_DIR" "$SKIP_BOOTBIN"