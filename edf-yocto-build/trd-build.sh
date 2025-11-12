#!/bin/bash

###############################################################################
# Copyright (C) 2025 Advanced Micro Devices, Inc. All Rights Reserved.
# SPDX-License-Identifier: MIT
###############################################################################

#
# Build script for EDF Yocto Setup and EDF Yocto Build xc2ve3858 TRDs
# sdtgen: "https://edf.amd.com/sswreleases/rel-v2025.2/sdt/2025.2/2025.2_1111_1_11112340/external/versal-2ve-2vm-vek385-revb-sdt-seg/versal-2ve-2vm-vek385-revb-sdt-seg_2025.2_1111_1_11112340.tar.gz"
# wic image: "https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html"
#

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;95m'
RESET='\033[0m'

VERSION="2025.2"

BASE_DIR=$(pwd)
SDTGEN_OUT_DIR=""
XSA_FILE=""

OVERLAY_CDO=$BASE_DIR/../subsystem-restart-trd/isoutil-project/subsys-overlay.cdo
OUT_DIR=""

ARCH="versal2"
BOARD="vek385"
REV="revb"
PLATFORM="versal-2ve-2vm"

BOARD_DTS="${ARCH}-${BOARD}-${REV}"
OUT_DIR=""
SKIP_BOOTBIN=false
DEBUG=false

export SKIP_BOOTBIN
export DEBUG

# Function to display help
_show_help() {
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Build/Install script for Subsystem Restart TRD using EDF Yocto Setup"
        echo ""
        echo "Required (choose one):"
        echo "  -sdt <DIR>          Specify sdtgen output directory"
        echo "  -xsa <XSA>          Specify hardware design file"
        echo ""
        echo "Optional:"
        echo "  -cdo <CDO>          Specify overlay CDO file (default: $OVERLAY_CDO)"
        echo "  -dir <DIR>          Specify output directory (default: "$PLATFORM-"$BOARD"_$VERSION")"
        echo "  --no-bootbin        Skip EDF bootbin generation (default: $SKIP_BOOTBIN)"
        echo "  --debug             Enable debug output (default: $DEBUG)"
        echo "  --help              Display this help message and exit"
        echo ""
        echo "Examples:"
        echo "  $0 -sdt /path/to/sdtgen-output"
        echo "  $0 -xsa design.xsa"
        echo "  $0 -sdt /path/to/sdtgen-output -cdo custom.cdo --no-bootbin"
        echo "  $0 -sdt /path/to/sdtgen-output -dir /path/to/output"
        echo ""
        echo -e "Developer: Kush Jain <kush.jain@amd.com>\nSSW Platform Management Team"
        exit 0
}

_sanity_check() {
        # check whether Vitis or Vivado are present in the enviorment
        VITIS_BIN=$(which vitis)
        VIVADO_BIN=$(which vivado)
        if [ -z "$VITIS_BIN" ] && [ -z "$VIVADO_BIN" ]; then
                echo -e "[Error] ${RED} Neither Vitis nor Vivado found in PATH${RESET}"
                exit 1
        elif [ -n "$VITIS_BIN" ]; then
                echo -e "${GREEN}Found Vitis: $VITIS_BIN${RESET}"
        elif [ -n "$VIVADO_BIN" ]; then
                echo -e "${GREEN}Found Vivado: $VIVADO_BIN${RESET}"
        fi

        # check if bitbake setup and build scripts are present
        if [ ! -f "bitbake-setup.sh" ]; then
                echo -e "[Error] ${RED}Bitbake setup script not found!${RESET}"
                exit 1
        fi
        if [ ! -f "bitbake-build.sh" ]; then
                echo -e "[Error] ${RED}Bitbake build script not found!${RESET}"
                exit 1
        fi

        # check if overlay cdo exists or not
        if [ ! -f "$OVERLAY_CDO" ]; then
                echo -e "[Error] ${RED}Overlay CDO file not found: $OVERLAY_CDO${RESET}"
                exit 1
        fi
}

__display_build_config() {
        echo "========================================================"
        echo -e "${CYAN}Build Configuration:${RESET}"
        echo -e "  Architecture: ${GREEN}$ARCH${RESET}"
        echo -e "  Platform: ${GREEN}$PLATFORM${RESET}"
        echo -e "  Board: ${GREEN}$BOARD${RESET}"
        echo -e "  Revision: ${GREEN}$REV${RESET}"
        echo -e "  Version: ${GREEN}$VERSION${RESET}"
        if [ -n "$OUT_DIR" ]; then
        echo -e "  SDTGEN Output Dir: ${GREEN}$OUT_DIR${RESET}"
        else
        echo -e "  SDTGEN Output Dir: ${GREEN}"$PLATFORM-"$BOARD"-"$REV"_$VERSION"${RESET}"
        fi
        if [ -n "$XSA_FILE" ]; then
        echo -e "  XSA File: ${GREEN}$XSA_FILE${RESET}"
        fi
        echo -e "  Overlay CDO: ${GREEN}$OVERLAY_CDO${RESET}"
        echo -e "  Skip Bootbin EDF Build: ${GREEN}$SKIP_BOOTBIN${RESET}"
        echo "========================================================"
        echo ''
}

_get_absolute_path(){
        relativePath="$1"
        echo "$(cd "$(dirname "$relativePath")"; pwd)/$(basename "$relativePath")"
}

__build_edf_yocto() {
        # initiate EDF Yocto setup and build
        cd "$BASE_DIR"
        ./bitbake-setup.sh "$SDTGEN_OUT_DIR"
        if [ $? -ne 0 ]; then
        	echo -e "[Error] ${RED}EDF Yocto setup failed.${RESET}"
        	exit 1
        fi
}

___convert_xsa_to_sdtgen() {
        # convert XSA to SDTGEN output directory
        local workspace=$1
        echo -e "[Info] ${CYAN}Converting XSA to SDTGEN output directory${RESET}"
        echo -e "[Info] ${PURPLE}Running: sdtgen -xsa $XSA_FILE -board_dts $BOARD_DTS -dir $workspace${RESET}"
        
        # Run sdtgen in non-interactive mode: redirect stdin from /dev/null and output to stderr
        local output=$(sdtgen -xsa "$XSA_FILE" -board_dts "$BOARD_DTS" -dir "$workspace")
        local ret=$?
        if $DEBUG; then
                echo -e "[Debug] ${PURPLE}sdtgen output:${RESET}"
                echo "$output"
        fi
        if [ $ret -ne 0 ]; then
                echo -e "[Error] ${RED}sdtgen failed to convert XSA to SDT (exit code: $ret)${RESET}"
                exit 1
        fi
}

__apply_overlaycdo_to_sdtgen_out() {

        local workspace=""
        if [ -n "$OUT_DIR" ]; then
                workspace="$OUT_DIR"
        else
                workspace="$PLATFORM-"$BOARD"-"$REV"_$VERSION"
        fi
        if [ -d "$workspace" ]; then
                echo -e "[Warn] ${YELLOW}Workspace directory already exists, removing it...${RESET}"
                rm -rf $workspace
        fi

        # first convert xsa to sdtgen output directory is xsa is provided
        if [ -n "$XSA_FILE" ]; then
                ___convert_xsa_to_sdtgen "$workspace"
        else
                mkdir $workspace
                cp -r "$SDTGEN_OUT_DIR"/* $workspace/
        fi

        workspace=$(_get_absolute_path "$workspace")

        # find and navigate to the directory with .bif file(s) inside the workspace
        BIF_DIR=$(find "$workspace" -type f -name "*.bif" -exec dirname {} \; | sort -u | head -1)
        if [ -z "$BIF_DIR" ]; then
                echo -e "[Error] ${RED} No .bif files found${RESET}"
                exit 1
        else
                echo -e "[Info] ${CYAN}Found .bif files in directory: $BIF_DIR${RESET}"
        fi

        # Create backup directory at workspace root and backup original PDI files
        mkdir -p "$workspace/.orig_boot_files"
        if compgen -G "$workspace/*.pdi" > /dev/null; then
                echo -e "[Info] ${CYAN}Backing up original PDI files${RESET}"
                cp "$workspace"/*.pdi "$workspace/.orig_boot_files/"
        fi

        cd "$BIF_DIR"

        # generate new boot pdi by applying overlay cdo to boot .bif
        BOOT_BIF=$(find "$BIF_DIR" -type f -name "*boot.bif")
        if [ -z "$BOOT_BIF" ]; then
                echo -e "[Error] ${RED} No boot .bif file found${RESET}"
                exit 1
        fi
        echo -e "[Info] ${PURPLE}Applying overlay cdo to $BOOT_BIF${RESET}"
        bootgen -arch $(echo "$PLATFORM" | sed 's/-/_/g') -overlay_cdo "$OVERLAY_CDO" -image "$BOOT_BIF" -o "${BOOT_BIF%.bif}.pdi" -w

        # verify the modified boot pdi was generated successfully
        if [ -f "${BOOT_BIF%.bif}.pdi" ]; then
                echo -e "${GREEN}Successfully generated new boot PDI: ${BOOT_BIF%.bif}.pdi${RESET}"
                # Copy and replace the original PDI at workspace root
                BOOT_PDI_NAME=$(basename "${BOOT_BIF%.bif}.pdi")
                if [ -f "$workspace/$BOOT_PDI_NAME" ]; then
                        echo -e "[Info] ${CYAN}Replacing original PDI at workspace root${RESET}"
                        cp "${BOOT_BIF%.bif}.pdi" "$workspace/$BOOT_PDI_NAME"
                        echo -e "${GREEN}Successfully replaced: $workspace/$BOOT_PDI_NAME${RESET}"
                else
                        echo -e "[Warning] ${YELLOW}Original PDI not found at workspace root, copying new PDI${RESET}"
                        cp "${BOOT_BIF%.bif}.pdi" "$BASE_DIR/$workspace/"
                fi
        else
                echo -e "[Error] ${RED} generating new boot pdi with overlay cdo failed!${RESET}"
                exit 1
        fi

        SDTGEN_OUT_DIR=$workspace
}

_build_subsystem_restart_trd() {
        __apply_overlaycdo_to_sdtgen_out
        __build_edf_yocto
}

_copy_edf_build_artifacts() {
        local edf_build_dir="yocto/edf/build/"
        local xilinx_bootbin_dir="$edf_build_dir/tmp/work/*-amd-linux/xilinx-bootbin/*/xilinx-bootbin-*/"
        local output_dir="$BASE_DIR/edf-yocto-build-artifacts/"

        # create a new directory to copy build artifacts
        if [ -d "$output_dir" ]; then
                echo -e "[Warn] ${YELLOW}Output directory already exists, removing it...${RESET}"
                rm -rf "$output_dir"
        fi
        mkdir -p "$output_dir"

        # check if xilinx-bootbin directory exists
        if [ ! -d $xilinx_bootbin_dir ]; then
                echo -e "[Error] ${RED}Xilinx bootbin directory not found: $xilinx_bootbin_dir${RESET}"
                exit 1
        fi
        # check if xilinx-bootbin directory is not empty
        if [ -z "$(ls -A $xilinx_bootbin_dir)" ]; then
                echo -e "[Error] ${RED}Xilinx bootbin directory is empty: $xilinx_bootbin_dir${RESET}"
                exit 1
        fi

        cp -r $xilinx_bootbin_dir* "$output_dir"
        echo -e "${GREEN}Successfully copied EDF Yocto build artifacts to $output_dir${RESET}"
        find "$output_dir" -type f | sed "s|$output_dir|-> |"
}

main() {
        # command-line argument parser
        while [[ $# -gt 0 ]]; do
                case $1 in
                        --help)
                                _show_help
                                ;;
                        -sdt)
                                if [[ -n "$2" && "$2" != -* ]]; then
                                        SDTGEN_OUT_DIR="$(_get_absolute_path "$2")"
                                        shift 2
                                else
                                        echo -e "[Error] ${RED}Option -sdt requires a directory argument${RESET}"
                                        exit 1
                                fi
                                ;;
                        -xsa)
                                if [[ -n "$2" && "$2" != -* ]]; then
                                        XSA_FILE="$(_get_absolute_path "$2")"
                                        shift 2
                                else
                                        echo -e "[Error] ${RED}Option -xsa requires a file argument${RESET}"
                                        exit 1
                                fi
                                ;;
                        -cdo)
                                if [[ -n "$2" && "$2" != -* ]]; then
                                        OVERLAY_CDO="$(_get_absolute_path "$2")"
                                        shift 2
                                else
                                        echo -e "[Error] ${RED}Option -cdo requires a file argument${RESET}"
                                        exit 1
                                fi
                                ;;
                        -dir)
                                if [[ -n "$2" && "$2" != -* ]]; then
                                        OUT_DIR="$(_get_absolute_path "$2")"
                                        shift 2
                                else
                                        echo -e "[Error] ${RED}Option -dir requires an output directory argument${RESET}"
                                        exit 1
                                fi
                                ;;
                        --no-bootbin)
                                SKIP_BOOTBIN=true
                                shift
                                ;;
                        --debug)
                                DEBUG=true
                                shift
                                ;;
                        -*)
                                echo -e "[Error] ${RED}Unknown option: $1${RESET}"
                                _show_help
                                exit 1
                                ;;
                        *)
                                echo -e "[Error] ${RED}Unexpected argument: $1${RESET}"
                                _show_help
                                exit 1
                                ;;
                esac
        done

        # Validate: either -sdt or -xsa is required
        if [[ -z "$SDTGEN_OUT_DIR" && -z "$XSA_FILE" ]]; then
                echo -e "[Error] ${RED}Either -sdt <DIR> or -xsa <XSA> is required${RESET}"
                _show_help
                exit 1
        fi

        _sanity_check

        # Display configuration
        __display_build_config

        # Build subsystem restart TRD
        _build_subsystem_restart_trd

        echo ''
        echo -e "${RESET}TRD Build Completed... ${RESET}"

        # Copy EDF Yocto build artifacts to current workspace
        _copy_edf_build_artifacts

        exit 0
}

main "$@"
