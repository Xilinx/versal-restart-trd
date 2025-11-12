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
SDTGEN_OUT_DIR="$2"

EDF_YOCTO_MACHINE="vek385-subsystem-restart-trd"
EDF_YOCTO_LAYER="meta-subsystem-restart-bsp"

__debug_dump() {
        message="$1"
        output="$2"
        if [ $DEBUG == true ]; then
                echo -e "[Debug] ${PURPLE}${message}:${RESET}"
                echo "$output"
        fi
}

_edf_yocto_init() {
        # Initialize build environment
        if [ -n "$TEMPLATECONF" ]; then
                unset TEMPLATECONF
        fi

        # Navigate to yocto/edf directory
        if [ -z "$EDF_YOCTO_DIR" ]; then
                echo -e "[Error] ${RED}EDF_YOCTO_DIR is not set. Please provide the directory path.${RESET}"
                echo -e "${CYAN}💡Hint: ./bitbake-build.sh <path_to_edf_yocto_directory> <sdtgen_out_dir>${RESET}"
                exit 1
        fi

        if [ -d "$EDF_YOCTO_DIR" ]; then
                cd "$EDF_YOCTO_DIR"
        else
                echo -e "[Error] ${RED}Directory $EDF_YOCTO_DIR does not exist.${RESET}"
                exit 1
        fi

        # Check if edf-init-build-env exists
        if [ ! -f "edf-init-build-env" ]; then
                echo -e "[Error] ${RED}edf-init-build-env not found in $EDF_YOCTO_DIR${RESET}"
                exit 1
        fi

        echo -e "[Info] ${CYAN}Sourcing edf-init-build-env...${RESET}"
        if $DEBUG; then
                source edf-init-build-env build
        else
                source edf-init-build-env build > /dev/null 2>&1
        fi
        ret=$?
        if [ $ret -ne 0 ]; then
                echo -e "[Error] ${RED}Failed to source edf-init-build-env${RESET}"
                exit 1
        fi
}

_edf_yocto_trd_setup() {
        # create new layer for trd in EDF Yocto
        echo -e "[Info] ${CYAN}Adding Subsystem Restart TRD layer to EDF Yocto...${RESET}"

        # check if commands executed successfully or not
        output=$(bitbake-layers create-layer ../sources/${EDF_YOCTO_LAYER})
        __debug_dump "Creating layer ${EDF_YOCTO_LAYER}" "$output"
        ret=$?
        if [ $ret -ne 0 ]; then
                echo -e "[Error] ${RED}Failed to create layer ${EDF_YOCTO_LAYER}${RESET}"
                exit 1
        fi
        output=$(bitbake-layers add-layer ../sources/${EDF_YOCTO_LAYER})
        __debug_dump "Adding layer ${EDF_YOCTO_LAYER}" "$output"
        ret=$?
        if [ $ret -ne 0 ]; then
                echo -e "[Error] ${RED}Failed to add layer ${EDF_YOCTO_LAYER}${RESET}"
                exit 1
        fi

        # use gen-machine-conf to generate custom machine conf by inheriting default vek385 machine
        echo -e "[Info] ${CYAN}Generating custom machine configuration for Subsystem Restart TRD...${RESET}"
        if ! gen-machineconf parse-sdt --hw-description ${SDTGEN_OUT_DIR} --template ../sources/meta-amd-adaptive-socs/meta-amd-adaptive-socs-bsp/conf/machineyaml/versal-2ve-2vm-vek385-sdt-seg.yaml --machine-name ${EDF_YOCTO_MACHINE} -c ../sources/${EDF_YOCTO_LAYER}/conf; then
                echo -e "[Error] ${RED}Failed to generate custom machine configuration${RESET}"
                exit 1
        fi

        # copy recipe bsp files for pdi customization ( only for Subsystem Restart TRD )
        echo -e "[Info] ${CYAN}Copying recipe bsp files for Subsystem Restart TRD...${RESET}"
        mkdir -p ../sources/${EDF_YOCTO_LAYER}/recipes-bsp/bootbin
        cp -r $BASE_DIR/recipes-bsp/bootbin/* ../sources/${EDF_YOCTO_LAYER}/recipes-bsp/bootbin/
}

_edf_yocto_build() {
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
}

main() {
        _edf_yocto_init
        _edf_yocto_trd_setup
        _edf_yocto_build
        echo -e "${GREEN}Build process completed.${RESET}"

        EDF_YOCTO_MACHINE_UNDERSCORE=${EDF_YOCTO_MACHINE//-/_}
        BOOT_bin=$(find "${EDF_YOCTO_DIR}/build/tmp/work/${EDF_YOCTO_MACHINE_UNDERSCORE}-amd-linux/xilinx-bootbin/" -path "*/image/*.bin")
        if [ -f "$BOOT_bin" ]; then
                echo -e "[Image]${CYAN} BOOT PDI -> "$(cd "$(dirname "$BOOT_bin")"; pwd)/$(basename "$BOOT_bin")" ${RESET}"
        fi
}

main "$@"
