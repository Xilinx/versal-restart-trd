#!/bin/bash

###############################################################################
# Copyright (C) 2025 Advanced Micro Devices, Inc. All Rights Reserved.
# SPDX-License-Identifier: MIT
###############################################################################

#
# This script is used to build linux images for xc2ve3858 using EDF framework.
#

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;95m'
RESET='\033[0m'

BASE_DIR=$(pwd)
EDF_YOCTO_DIR="$1"
XC2VE3858_TRD="$2"
SDTGEN_OUT_DIR="$3"
SKIP_BOOTBIN="$4"

if [ "$XC2VE3858_TRD" == "subsystem-restart" ]; then
    EDF_YOCTO_MACHINE="vek385-subsystem-restart-trd"
    EDF_YOCTO_LAYER="meta-subsystem-restart-bsp"
elif [ "$XC2VE3858_TRD" == "power-states" ]; then
    EDF_YOCTO_MACHINE="vek385-power-states-trd"
    EDF_YOCTO_LAYER="meta-power-states-bsp"
else
    echo -e "[Error] ${RED}Invalid TRD type specified: $XC2VE3858_TRD${RESET}"
    echo -e "${CYAN}💡Hint: Supported TRD types are 'subsystem-restart' and 'power-states'.${RESET}"
    exit 1
fi

# Initialize build environment
if [ -n "$TEMPLATECONF" ]; then
    unset TEMPLATECONF
fi

# Navigate to yocto/edf directory
if [ -z "$EDF_YOCTO_DIR" ]; then
    echo -e "[Error] ${RED}EDF_YOCTO_DIR is not set. Please provide the directory path.${RESET}"
    echo -e "${CYAN}💡Hint: ./bitbake-build.sh <path_to_edf_yocto_directory>${RESET}"
    exit 1
fi

if [ -d "$EDF_YOCTO_DIR" ]; then
    cd "$EDF_YOCTO_DIR"
else
    echo -e "[Error] ${RED}Directory $EDF_YOCTO_DIR does not exist.${RESET}"
    exit 1
fi

# Check if internal-edf-init-build-env exists
if [ ! -f "internal-edf-init-build-env" ]; then
    echo -e "[Error] ${RED}internal-edf-init-build-env not found in $EDF_YOCTO_DIR${RESET}"
    exit 1
fi

echo -e "[Info] ${CYAN}Sourcing internal-edf-init-build-env...${RESET}"
if ! source internal-edf-init-build-env build; then
    echo -e "[Error] ${RED}Failed to source internal-edf-init-build-env${RESET}"
    exit 1
fi

# create new layer for trd in EDF Yocto ( only for Subsystem Restart TRD )
if [ "subsystem-restart" == "$XC2VE3858_TRD" ]; then
    echo -e "[Info] ${CYAN}Adding Subsystem Restart TRD layer to EDF Yocto...${RESET}"
    # check if commands executed successfully or not
    if ! bitbake-layers create-layer ../sources/${EDF_YOCTO_LAYER}; then
        echo -e "[Error] ${RED}Failed to create layer ${EDF_YOCTO_LAYER}${RESET}"
        exit 1
    fi
    if ! bitbake-layers add-layer ../sources/${EDF_YOCTO_LAYER}; then
        echo -e "[Error] ${RED}Failed to add layer ${EDF_YOCTO_LAYER}${RESET}"
        exit 1
    fi
fi

# use gen-machine-conf to generate custom machine conf by inheriting default vek385 machine ( only for Subsystem Restart TRD )
if [ "subsystem-restart" == "$XC2VE3858_TRD" ]; then
    echo -e "[Info] ${CYAN}Generating custom machine configuration for Subsystem Restart TRD...${RESET}"
    if ! gen-machineconf parse-sdt --hw-description ${SDTGEN_OUT_DIR} --template ../sources/meta-amd-adaptive-socs/meta-amd-adaptive-socs-bsp/conf/machineyaml/versal-2ve-2vm-vek385-sdt-seg.yaml --machine-name ${EDF_YOCTO_MACHINE} -c ../sources/${EDF_YOCTO_LAYER}/conf; then
        echo -e "[Error] ${RED}Failed to generate custom machine configuration${RESET}"
        exit 1
    fi
fi

# copy recipe bsp files for pdi customization ( only for Subsystem Restart TRD )
if [ "subsystem-restart" == "$XC2VE3858_TRD" ]; then
    echo -e "[Info] ${CYAN}Copying recipe bsp files for Subsystem Restart TRD...${RESET}"
    mkdir -p ../sources/${EDF_YOCTO_LAYER}/recipes-bsp/bootbin
    cp -r $BASE_DIR/$XC2VE3858_TRD/recipes-bsp/bootbin/* ../sources/${EDF_YOCTO_LAYER}/recipes-bsp/bootbin/
fi

# Build EDF Images using pre-built Machine
if [ "$SKIP_BOOTBIN" = false ]; then
    echo -e "[Info] ${PURPLE}Building EDF Images using pre-built Machine...${RESET}"
    if ! MACHINE=${EDF_YOCTO_MACHINE} bitbake xilinx-bootbin; then
        echo -e "[Error] ${RED}Failed to build EDF Images using pre-built Machine${RESET}"
        exit 1
    fi
else
    echo -e "[Warn] ${YELLOW}Skipped building EDF pre-built images${RESET}"
fi

# Build Image and rootfs
# if [ "$SKIP_CORE_IMAGE" = false ]; then
#     echo -e "[Info] ${PURPLE}Building Image and rootfs...${RESET}"
#     MACHINE=amd-cortexa78-mali-common bitbake core-image-full-cmdline
# else
#     echo -e "[Warn] ${YELLOW}Skipped building EDF core images${RESET}"
# fi

echo -e "${GREEN}Build process completed.${RESET}"