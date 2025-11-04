#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;95m'
RESET='\033[0m'

VERBOSE=false
CACHE=false
BOARD="vek385"

set -e  # Exit on any error

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

# Configuration
PACKAGE_NAME="subsys-restart-app"
PACKAGE_VERSION="2025.2"
PACKAGE_RELEASE="1"
SOURCE_DIR="BUILD/${PACKAGE_NAME}-${PACKAGE_VERSION}"
TARBALL="SOURCES/${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.gz"
SPEC_FILE="SPECS/${PACKAGE_NAME}.spec"

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

# Create necessary directories
mkdir -p SOURCES BUILDROOT RPMS SRPMS

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${RESET}"
rm -f SOURCES/*.tar.gz
rm -f RPMS/noarch/*.rpm
rm -f SRPMS/*.src.rpm

# Create source tarball
echo -e "${CYAN}Creating source tarball...${RESET}"
if [ "$VERBOSE" = true ]; then
    tar -czf "$TARBALL" -C BUILD "${PACKAGE_NAME}-${PACKAGE_VERSION}"
else
    tar -czf "$TARBALL" -C BUILD "${PACKAGE_NAME}-${PACKAGE_VERSION}" >/dev/null 2>&1
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
    # check if build is not succeeds
    if rpmbuild --define "board $BOARD" --define "_topdir $(pwd)" -ba "$SPEC_FILE"; then
        :
    else
        echo -e "${RED}Error: RPM build failed!${RESET}"
        exit 1
    fi
else
    if rpmbuild --define "board $BOARD" --define "_topdir $(pwd)" -ba "$SPEC_FILE" >/dev/null 2>&1; then
        :
    else
        echo -e "${RED}Error: RPM build failed!${RESET}"
        exit 1
    fi
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