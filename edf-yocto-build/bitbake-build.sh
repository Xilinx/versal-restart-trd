#!/bin/bash

###############################################################################
#
# Copyright (C) 2025 Advanced Micro Devices, Inc. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
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
BOARD="$3"
PLATFORM="$4"

EDF_YOCTO_MACHINE="$BOARD-subsystem-restart-trd"
EDF_YOCTO_LAYER="meta-subsystem-restart-bsp"
EDF_VEK385_DEFAULT_MACHINE_YAML="../sources/meta-amd-adaptive-socs/meta-amd-adaptive-socs-bsp/conf/machineyaml/$(echo "$PLATFORM" | sed 's/_/-/g')-$BOARD-sdt-seg.yaml"

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

        # use gen-machine-conf to generate custom machine conf by inheriting default $BOARD machine
        echo -e "[Info] ${CYAN}Generating custom machine configuration for Subsystem Restart TRD...${RESET}"
        echo -e "[Info] ${PURPLE}Disabling Zephyr R52-0 multiconfig build...${RESET}"
        if ! gen-machineconf parse-sdt --hw-description ${SDTGEN_OUT_DIR} --template ${EDF_VEK385_DEFAULT_MACHINE_YAML} --machine-name ${EDF_YOCTO_MACHINE} -c ../sources/${EDF_YOCTO_LAYER}/conf --add-config CONFIG_YOCTO_BBMC_CORTEXR52_0_ZEPHYR=n; then
                echo -e "[Error] ${RED}Failed to generate custom machine configuration${RESET}"
                exit 1
        fi

        # copy recipe bsp files for pdi customization ( only for Subsystem Restart TRD )
        echo -e "[Info] ${CYAN}Copying recipe bsp files for Subsystem Restart TRD...${RESET}"
        mkdir -p ../sources/${EDF_YOCTO_LAYER}/recipes-bsp/bootbin
        cp -r $BASE_DIR/../$(echo "$PLATFORM" | sed 's/-/_/g')/$BOARD/recipes-* ../sources/${EDF_YOCTO_LAYER}/
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
        __debug_dump "Searching BOOT PDI..." "$BOOT_bin"
        ret=$?
        if [ -z "$BOOT_bin" ]; then
                echo -e "[Error] ${RED}Failed to search BOOT PDI${RESET}"
                exit 1
        fi
        if [ -f "$BOOT_bin" ]; then
                echo -e "[Image]${CYAN} BOOT PDI -> "$(cd "$(dirname "$BOOT_bin")"; pwd)/$(basename "$BOOT_bin")" ${RESET}"
        fi
}

main "$@"
