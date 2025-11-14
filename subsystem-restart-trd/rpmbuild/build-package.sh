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

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;95m'
RESET='\033[0m'

VERBOSE=false
CACHE=false
BOARD="vek385"
PLATFORM="versal_2ve_2vm"

# Configuration
PACKAGE_NAME="subsys-restart-app"
PACKAGE_VERSION="2025.2"
PACKAGE_RELEASE="1"
SOURCE_DIR="BUILD/"
TARBALL="SOURCES/${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.gz"
SPEC_FILE="SPECS/${PACKAGE_NAME}.spec"

declare -A boardMap
set -e  # Exit on any error

_load_board_info() {
	local yaml_file="$1"
	
	if [ ! -f "$yaml_file" ]; then
		echo -e "[Error] ${RED}Board configuration file not found: $yaml_file${RESET}"
		exit 1
	fi
	
	# Format: platform:board or platform:board:property
	while IFS='|' read -r key value; do
		boardMap["$key"]="$value"
	done < <(awk '
		BEGIN { platform = ""; board = "" }
		
		# Skip empty lines and comments
		/^[[:space:]]*$/ || /^[[:space:]]*#/ { next }
		
		{
			# Calculate indent level (0, 2, 4+ spaces)
			indent = match($0, /[^[:space:]]/) - 1
			gsub(/^[[:space:]]+|[[:space:]]+$/, "")  # Trim whitespace
			
			# Extract key and value
			if (match($0, /^([^:]+):[[:space:]]*(.*)[[:space:]]*$/, arr)) {
				key = arr[1]
				value = arr[2]
				
				if (indent == 0) {
					# Platform level
					platform = key
					board = ""
				} else if (indent < 4 && platform != "") {
					# Board level (indent 2)
					board = key
					print platform ":" board "|"
				} else if (indent >= 4 && platform != "" && board != "") {
					# Property level (indent 4+)
					print platform ":" board ":" key "|" value
				}
			}
		}
	' "$yaml_file")

}

_sanity_check() {
    # Check whether rpm is installed
    if ! command -v rpmbuild &> /dev/null; then
        echo -e "${RED}Error: rpmbuild is not installed!${RESET}"
        exit 1
    fi

    # Set output redirection based on verbose flag
    if [ "$VERBOSE" = true ]; then
        OUTPUT_REDIRECT=""
        echo -e "${PURPLE}Verbose mode enabled${RESET}"
    else
        OUTPUT_REDIRECT=">/dev/null 2>&1"
    fi

    # check if given $BOARD is supported or not
    local found_board=false
    for key in "${!boardMap[@]}"; do
            IFS=':' read -r platform board <<< "$key"
            if [[ "$board" == "$BOARD" ]]; then
                    found_board=true
                    PLATFORM="$platform"
                    if $VERBOSE; then
                            echo -e "[Debug] ${PURPLE}Board: $board Platform: $platform${RESET}"
                    fi
                    break
            fi
    done
    if ! $found_board; then
            echo -e "[Error] ${RED}Unsupported board: $BOARD${RESET}"
            exit 1
    fi
}

_build_rpm_package() {
    # freshly copy artifacts from apu_app to BUILD
    if [ "$CACHE" = false ]; then
        echo -e "${YELLOW}Copying artifacts from apu_app to BUILD directory...${RESET}"
        cp -r ../apu_app/*.py ${SOURCE_DIR}
    fi

    echo -e "${CYAN}Building RPM package: ${PACKAGE_NAME}-${PACKAGE_VERSION}-${PACKAGE_RELEASE}${RESET}"

    # Check if required directories and files exist
    if [ ! -d "$SOURCE_DIR" ]; then
        echo -e "${RED}Error: Source directory $SOURCE_DIR not found!${RESET}"
        exit 1
    fi

    if [ ! -f "$SPEC_FILE" ]; then
        echo -e "${RED}Error: Spec file $SPEC_FILE not found!${RESET}"
        exit 1
    fi

    # Clean previous builds directories
    echo -e "${YELLOW}Cleaning previous builds...${RESET}"
    rm -rf SOURCES
    rm -rf RPMS
    rm -rf SRPMS

    # Create necessary directories
    mkdir -p SOURCES RPMS/noarch SRPMS

    # Create source tarball
    echo -e "${CYAN}Creating source tarball...${RESET}"
    if [ "$VERBOSE" = true ]; then
        tar -czf "$TARBALL" --transform "s,^,${PACKAGE_NAME}-${PACKAGE_VERSION}/," -C BUILD .
    else
        tar -czf "$TARBALL" --transform "s,^,${PACKAGE_NAME}-${PACKAGE_VERSION}/," -C BUILD . >/dev/null 2>&1
    fi

    # Verify tarball was created
    if [ ! -f "$TARBALL" ]; then
        echo -e "${RED}Error: Failed to create tarball $TARBALL${RESET}"
        exit 1
    fi

    echo -e "${GREEN}Source tarball created: $TARBALL${RESET}"

    # Build RPM package
    echo -e "${CYAN}Building RPM package...${RESET}"
    if [ "$VERBOSE" = true ]; then
        # check if build succeeds
        if rpmbuild --define "board $BOARD" --define "platform $PLATFORM" --define "_topdir $(pwd)" -ba "$SPEC_FILE"; then
            :
        else
            echo -e "${RED}Error: RPM build failed!${RESET}"
            exit 1
        fi
    else
        if rpmbuild --define "board $BOARD" --define "platform $PLATFORM" --define "_topdir $(pwd)" -ba "$SPEC_FILE" >/dev/null 2>&1; then
            :
        else
            echo -e "${RED}Error: RPM build failed!${RESET}"
            exit 1
        fi
    fi

    # Cleanup artifacts
    if [ "$CACHE" = false ]; then
        echo -e "${YELLOW}Deleting locally copied artifacts...${RESET}"
        rm -rf BUILD/*.py "BUILD/${PACKAGE_NAME}-${PACKAGE_VERSION}"
    fi

    # Check if build was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Build successful!${RESET}"
        echo -e "${PURPLE}Generated package(s):${RESET}"
        ls -la RPMS/noarch/*.rpm 2>/dev/null || echo "No binary RPMs found"
        ls -la SRPMS/*.src.rpm 2>/dev/null || echo "No source RPMs found"
    else
        echo -e "${RED}Build failed!${RESET}"
        exit 1
    fi
}

main() {
    _load_board_info $(dirname "${BASH_SOURCE[0]}")/"../../supported-boards.yaml"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b|--board)
                BOARD=$2
                shift
                shift
                ;;
            -c|--cache)
                CACHE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [-b|--board <board>] [-c|--cache] [-v|--verbose] [-h|--help]"
                echo "  -b, --board      Specify the target board for the build (default: $BOARD)"
                echo "  -c, --cache      Use cached build artifacts (default: $CACHE)"
                echo "  -v, --verbose    Show detailed build output"
                echo "  -h, --help       Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
        esac
    done

    _sanity_check

    _build_rpm_package
}

main "$@"