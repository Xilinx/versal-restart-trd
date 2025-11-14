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

#*****************************************************************************
#
# Subsystem Restart RPM Package Installation Verification Script
#
# This script verifies that all components of the Subsystem Restart application
# have been installed and configured correctly.
#
#*****************************************************************************

# Color definitions for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;95m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Verification counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Function to print test results
print_result() {
    local test_name="$1"
    local result="$2"
    local details="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ "$result" = "PASS" ]; then
        echo -e "✅ ${GREEN}PASS${RESET} - $test_name"
        [ -n "$details" ] && echo -e "   ${CYAN}$details${RESET}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "❌ ${RED}FAIL${RESET} - $test_name"
        [ -n "$details" ] && echo -e "   ${RED}$details${RESET}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# Function to print section headers
print_section() {
    echo ""
    echo -e "${PURPLE}==== $1 ====${RESET}"
    echo ""
}

# Function to check if a file exists
check_file_exists() {
    local file_path="$1"
    local description="$2"
    
    if [ -f "$file_path" ]; then
        print_result "$description" "PASS" "Found: $file_path"
    else
        print_result "$description" "FAIL" "Missing: $file_path"
    fi
}

# Function to check if a service is enabled
check_service_enabled() {
    local service_name="$1"
    local description="$2"
    
    if systemctl is-enabled "$service_name" >/dev/null 2>&1; then
        print_result "$description" "PASS" "Service $service_name is enabled"
    else
        print_result "$description" "FAIL" "Service $service_name is not enabled"
    fi
}

# Function to check if a service is active
check_service_active() {
    local service_name="$1"
    local description="$2"
    
    if systemctl is-active "$service_name" >/dev/null 2>&1; then
        local pid=$(systemctl show -p MainPID --value "$service_name")
        print_result "$description" "PASS" "Service $service_name is running (PID: $pid)"
    else
        local status=$(systemctl is-active "$service_name")
        print_result "$description" "FAIL" "Service $service_name is $status"
    fi
}

# Function to check if a process is running
check_process_running() {
    local process_name="$1"
    local description="$2"
    
    local pid=$(pgrep -f "$process_name")
    if [ -n "$pid" ]; then
        print_result "$description" "PASS" "Process running with PID: $pid"
    else
        print_result "$description" "FAIL" "Process not found: $process_name"
    fi
}

# Start verification
clear
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║           Subsystem Restart Package Installation Verification         ║${RESET}"
echo -e "${BLUE}║                      Version 2025.2                                   ║${RESET}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════════╝${RESET}"

print_section "1. Python Scripts Installation Check"

# Check all Python scripts
check_file_exists "/opt/subsys-restart-app/subsys-restart-app.py" "Main Subsystem Restart Application Script"
check_file_exists "/opt/subsys-restart-app/subsys-restart-cmd.py" "Command-line Interface Script"
check_file_exists "/opt/subsys-restart-app/subsys-restart-funcs.py" "Subsystem Restart Functions Script"
check_file_exists "/opt/subsys-restart-app/utility.py" "Utility Functions Script"

# Check script permissions
if [ ! -x "$(which sc_app)" ]; then
    if [ -f "/opt/subsys-restart-app/subsys-restart-app.py" ]; then
        if [ -x "/opt/subsys-restart-app/subsys-restart-app.py" ]; then
            print_result "Main script executable permissions" "PASS" "subsys-restart-app.py is executable"
        else
            print_result "Main script executable permissions" "FAIL" "subsys-restart-app.py is not executable"
        fi
    fi
fi

print_section "2. Service Scripts Installation Check"

# Check service setup scripts
check_file_exists "/opt/subsys-restart-app/scripts/auto-login_service.sh" "Auto-login Service Script"
if [ ! -x "$(which sc_app)" ]; then
    check_file_exists "/opt/subsys-restart-app/scripts/auto-start-subsys-restart_service.sh" "Auto-start Service Script"
fi

print_section "3. Auto-login Service Verification"

# Check auto-login configuration files
check_file_exists "/etc/systemd/system/serial-getty@ttyAMA1.service.d/autologin.conf" "Auto-login Config (ttyAMA1)"
check_file_exists "/etc/systemd/system/serial-getty@ttyPS0.service.d/autologin.conf" "Auto-login Config (ttyPS0)"

# Check if auto-login services are enabled/active
check_service_enabled "serial-getty@ttyAMA1.service" "Auto-login Service Enabled (ttyAMA1)"
check_service_active "serial-getty@ttyAMA1.service" "Auto-login Service Active (ttyAMA1)"

# Check console configuration in kernel cmdline
if grep -q "console=ttyAMA1" /proc/cmdline; then
    print_result "Kernel console configuration" "PASS" "Console configured for ttyAMA1"
elif grep -q "console=ttyPS0" /proc/cmdline; then
    print_result "Kernel console configuration" "PASS" "Console configured for ttyPS0"
else
    print_result "Kernel console configuration" "FAIL" "No matching console configuration found"
fi

print_section "4. Subsystem Restart Service Verification"

# Check subsystem-restart service
if [ ! -x "$(which sc_app)" ]; then
    check_file_exists "/etc/systemd/system/subsystem-restart.service" "Subsystem Restart Service File"
    check_service_enabled "subsystem-restart.service" "Subsystem Restart Service Enabled"
    check_service_active "subsystem-restart.service" "Subsystem Restart Service Active"
fi

# Verify service configuration
if [ ! -x "$(which sc_app)" ]; then
    if [ -f "/etc/systemd/system/subsystem-restart.service" ]; then
        if grep -q "/opt/subsys-restart-app/subsys-restart-app.py" /etc/systemd/system/subsystem-restart.service; then
            print_result "Service configuration" "PASS" "Service points to correct Python script"
        else
            print_result "Service configuration" "FAIL" "Service configuration incorrect"
        fi
    fi
fi

print_section "5. Background Process Verification"

# Check if subsys-restart-app.py is running in background
if [ ! -x "$(which sc_app)" ]; then
    check_process_running "subsys-restart-app.py" "Subsystem Restart Application Background Process"
fi

# Check if the process is running with correct user
if [ ! -x "$(which sc_app)" ]; then
    if pgrep -f "subsys-restart-app.py" >/dev/null; then
        subsys_restart_user=$(ps -o user= -p $(pgrep -f "subsys-restart-app.py") | tr -d ' ')
        if [ "$subsys_restart_user" = "root" ]; then
            print_result "Process user verification" "PASS" "Subsystem Restart app running as root user"
        else
            print_result "Process user verification" "FAIL" "Subsystem Restart app running as '$subsys_restart_user' (should be root)"
        fi
    fi
fi

print_section "6. System Integration Verification"

# Check if we can communicate with the Subsystem Restart application
if [ -f "/opt/subsys-restart-app/subsys-restart-cmd.py" ]; then
    print_result "Command-line interface availability" "PASS" "Subsystem Restart command-line interface installed"
else
    print_result "Command-line interface availability" "FAIL" "Subsystem Restart command-line interface missing"
fi

# Check Python dependencies
if command -v python3 >/dev/null 2>&1; then
    local python_version=$(python3 --version 2>&1)
    print_result "Python3 availability" "PASS" "$python_version available"
else
    print_result "Python3 availability" "FAIL" "Python3 not found in PATH"
fi

# Check if required system commands are available
if [ ! -x "$(which sc_app)" ]; then
    for cmd in devmem2 systemctl; do
        if command -v "$cmd" >/dev/null 2>&1; then
            print_result "System command: $cmd" "PASS" "$cmd is available"
        else
            print_result "System command: $cmd" "FAIL" "$cmd not found"
        fi
    done
fi

print_section "7. Final Summary"

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║                    VERIFICATION RESULTS                  ║${RESET}"
echo -e "${BLUE}╠══════════════════════════════════════════════════════════╣${RESET}"
echo -e "${BLUE}║${RESET} Total Checks: ${CYAN}$TOTAL_CHECKS${RESET}"
echo -e "${BLUE}║${RESET} Passed: ${GREEN}$PASSED_CHECKS${RESET}"
echo -e "${BLUE}║${RESET} Failed: ${RED}$FAILED_CHECKS${RESET}"

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET} ${GREEN}🎉 ALL CHECKS PASSED! 🎉${RESET}"
    echo -e "${BLUE}║${RESET} ${GREEN}Subsystem Restart Application is fully operational!${RESET}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${CYAN}💡 Usage Instructions:${RESET}"
    echo -e "${YELLOW}   • Main service runs automatically in background${RESET}"
    echo -e "${YELLOW}   • Use: python3 /opt/subsys-restart-app/subsys-restart-cmd.py${RESET}"
    echo -e "${YELLOW}   • Check status: systemctl status subsystem-restart${RESET}"
    echo -e "${YELLOW}   • View logs: journalctl -u subsystem-restart -f${RESET}"
else
    echo -e "${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET} ${RED}⚠️  SOME CHECKS FAILED ⚠️${RESET}"
    echo -e "${BLUE}║${RESET} ${RED}Please review the failed items above${RESET}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${YELLOW}🔧 Troubleshooting:${RESET}"
    echo -e "${CYAN}   • Check service status: systemctl status subsystem-restart${RESET}"
    echo -e "${CYAN}   • View logs: journalctl -u subsystem-restart -n 20${RESET}"
    echo -e "${CYAN}   • Manual start: systemctl start subsystem-restart${RESET}"
    echo -e "${CYAN}   • Restart services: systemctl daemon-reload${RESET}"
fi

echo ""
exit $FAILED_CHECKS
