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

REPO_BIN=""
EDF_YOCTO_DIR="$BASE_DIR/yocto/edf"

__debug_dump() {
        message="$1"
        output="$2"
        if [ $DEBUG == true ]; then
                echo -e "[Debug] ${PURPLE}${message}:${RESET}"
                echo "$output"
        fi
}

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
if [ -d "$EDF_YOCTO_DIR" ]; then
	echo -e "[Warn] ${YELLOW}EDF Yocto directory already exists.${RESET}"
	echo "What would you like to do (auto remove in 10 seconds)? (r)emove, (e)xit"
	# wait 10 seconds for user input
	read -t 10 -r action
	if [ $? -ne 0 ]; then
		action="r"
	fi
	case $action in
		r|R)
			echo -e "[Info] ${CYAN}Removed existing EDF Yocto directory...${RESET}"
			rm -rf "$EDF_YOCTO_DIR"
			;;
		e|E)
			echo -e "[Info] ${CYAN}Exiting setup.${RESET}"
			exit 0
			;;
		*)
			echo -e "[Error] ${RED}Invalid option. Exiting setup.${RESET}"
			exit 1
			;;
	esac
fi
mkdir -p "$EDF_YOCTO_DIR"
cd "$EDF_YOCTO_DIR"
if [ ! -x $REPO_BIN ]; then
	echo -e "[Error] ${RED}repo tool not found or not executable.${RESET}"
	exit 1
fi
output="$("$REPO_BIN" init -u https://github.com/Xilinx/yocto-manifests.git -b rel-v$RELEASE -m default-edf.xml)"
__debug_dump "EDF Yocto Initialization" "$output"
ret=$?
if [ $ret -ne 0 ]; then
	echo -e "[Error] ${RED}Failed to initialize EDF Yocto repo.${RESET}"
	exit 1
fi

# Set Development environment in repo
output="$("$REPO_BIN" sync)"
__debug_dump "EDF Yocto Repo sync" "$output"
ret=$?
if [ $ret -ne 0 ]; then
	echo -e "[Error] ${RED}Failed to sync EDF Yocto repo.${RESET}"
	exit 1
fi
timestamp=$(date +"%Y%m%d%H%M%S")
branchname="vek385-$timestamp"
output="$("$REPO_BIN" start "$branchname" --all)"
__debug_dump "EDF Yocto setup" "$output"
ret=$?
if [ $ret -ne 0 ]; then
	echo -e "[Error] ${RED}Failed to setup EDF Yocto.${RESET}"
	exit 1
fi

# Launch EDF Yocto build
cd "$BASE_DIR"
./bitbake-build.sh "$EDF_YOCTO_DIR" "$SDTGEN_OUT_DIR"
if [ $? -ne 0 ]; then
	echo -e "[Error] ${RED}EDF Yocto build failed.${RESET}"
	exit 1
fi
