#!/usr/bin/python3

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
# Python Module is a utility tool for Subsystem Restart TRD
#

import sys
import subprocess
import os
import shutil

minPythonVersion = (3, 6, 0)

fmt = {
        "PURPLE": lambda msg: "\033[95m" + "\033[1m" + msg + "\033[0m",
        "CYAN": lambda msg: "\033[96m" + "\033[1m" + msg + "\033[0m",
        "DARKCYAN": lambda msg: "\033[36m" + "\033[1m" + msg + "\033[0m",
        "BLUE": lambda msg: "\033[94m" + "\033[1m" + msg + "\033[0m",
        "GREEN": lambda msg: "\033[92m" + "\033[1m" + msg + "\033[0m",
        "YELLOW": lambda msg: "\033[93m" + "\033[1m" + msg + "\033[0m",
        "RED": lambda msg: "\033[91m" + "\033[1m" + msg + "\033[0m",
        "UNDERLINE": lambda msg: "\033[4m" + "\033[1m" + msg + "\033[0m",
        "DEFAULT": lambda msg: "\033[1m" + msg + "\033[0m",
}
"""'
Message formating data structure
Choose from: PURPLE, CYAN, DARKCYAN, BLUE, GREEN, YELLOW, RED, UNDERLINE
"""

DEV_HOST = "versal2"            # indicates whether application is running on Versal2 or System Controller
LOG_DEBUG = 0

logPrint = lambda msg: print(fmt["DEFAULT"](msg))
if LOG_DEBUG:
        logDebug = lambda msg: print("[DEBUG]" + fmt["PURPLE"](msg))
else:
        logDebug = lambda msg: None
logOut = lambda msg: print(fmt["GREEN"](msg))
logInfo = lambda msg: print("[INFO] " + fmt["CYAN"](msg))
logWarn = lambda msg: print("[WARNING] " + fmt["YELLOW"](msg))
logErr  = lambda msg: print("[ERROR] " + fmt["RED"](msg))

def is_root_user():
        """Checks if the current user is root."""
        return os.getuid() == 0

def execute_command(command):
        try:
                ret = subprocess.run(
                        command,
                        shell=True,
                        check=True,
                        universal_newlines=True,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT,
                )
        except subprocess.CalledProcessError as e:
                if e.stdout:
                        logPrint(e.stdout)
                if e.stderr:
                        logErr(e.stderr)
                raise

        return ret.returncode, ret.stdout

def pretty_table_print(header: list, data: list, colour="CYAN") -> None:
        """dumps prints in table format"""
        # Calculate the width of each column
        widths = [max(len(str(val)) for val in col) for col in zip(header, *data)]
        print(fmt[colour]("/" + "┬".join("-" * (width + 2) for width in widths) + "\\"))
        # Print the header
        print(
                fmt[colour]("| " + " | ".join("{:^{}}".format(val, width) for val, width in zip(header, widths)) + " |")
        )
        # Print the separator
        print(fmt[colour]("|" + "|".join("-" * (width + 2) for width in widths) + "|"))
        # Print the table data
        for row in data:
                print(
                        fmt[colour]("| " + " | ".join("{:^{}}".format(val, width) for val, width in zip(row, widths)) + " |")
                )
        print(fmt[colour]("\\" + "┻".join("-" * (width + 2) for width in widths) + "/"))

def sanity_check():
        '''sanity checker for the app'''

        # check python version
        if sys.version_info < minPythonVersion:
                logErr(f"Python v{'.'.join(map(str, minPythonVersion))} or higher is required, found v{'.'.join(map(str, sys.version_info[:3]))}. Please update your Python version!")
                return False
        else:
                logDebug(f"Python version found: v{'.'.join(map(str, sys.version_info[:3]))}")

        # check whether application launched under root user
        if not os.getuid() == 0:
                logDebug("Application must run as a root user!")
                return False

        if DEV_HOST == "versal2":
                # check whether required linux packages are installed and available in environment
                reqPackages = ["devmem2"]
                for pkg in reqPackages:
                        if not shutil.which(pkg):
                                logErr(f"Required package '{pkg}' is not installed.")
                                return False
        # check for sc_app version if app is running on System Controller device
        elif DEV_HOST == "sysctl":
                sysctlVerCheckCmd = "sc_app -c version"
                ret, stdout = execute_command(sysctlVerCheckCmd)
                if (ret != 0):
                        logErr("sc_app version check failed!")
                        return False

                versionInfo = stdout.lstrip().splitlines()[0]
                versionStr = versionInfo.split()[-1].lstrip()
                try:
                        # Parse version as tuple of integers (handling for minor release versions)
                        versionParts = tuple(int(x) for x in versionStr.split('.'))
                        minVersion = (1, 25)

                        # Compare tuples element-by-element
                        if versionParts < minVersion:
                                logErr(f"sc_app version found: {versionStr}, need >= 1.25 for app!")
                                logWarn("Please update the System Controller image...")
                                return False
                except ValueError:
                        logErr(f"Failed to parse sc_app version: {versionStr}")
                        return False

        print()
        return True

def set_ddr_addr_value(addr, mask, value, length='l'):
        '''Performs DDR mask writes the value to given address ( by default writes all 64-bits / 8 bytes )'''

        if not os.getuid() == 0:
                logDebug("DDR Memory Writes require Root Privileges!")
                sys.exit(1)

        currValue, _ = get_ddr_addr_value(addr)  # Read the current value before writing
        if currValue is False:
                logErr("Failed to read current DDR value before writing...")
                sys.exit(1)
        currValue = currValue & ~mask       # Apply mask to clear bits to write 
        newValue = currValue | value          # set the bits to write

        # versal device write using devmem
        if DEV_HOST == "versal2":
                try:
                        cmd = f"devmem2 {addr} {length} {newValue:#x}"
                        ret, stdout = execute_command(cmd)
                        logDebug(f"cmd: {cmd}")
                        logDebug(f"ret: {ret}")
                        if (ret != 0):
                                logErr(f"Writing to DDR failed: {stdout if stdout else 'NULL'}")
                                return False
                        addrMap = int(stdout.strip().splitlines()[-1].split()[-4].strip('():'), 16)
                        logDebug(f"DDR Write> [{addr:#x}] @ {addrMap:#x} : {value:#x} -> {newValue:#x}")
                except subprocess.CalledProcessError:
                        logErr(f"Writing to DDR failed for address {addr:#x}")
                        sys.exit(1)
        # sysctl device write using xsdb
        elif DEV_HOST == "sysctl":
                try:
                        cmd = f"xsdb /root/write.tcl {addr} {newValue:#x}"
                        ret, stdout = execute_command(cmd)
                        if (ret != 0):
                                logErr(f"Writing to DDR failed: {stdout if stdout else 'NULL'}")
                                return False
                        logDebug(f"DDR Write> [{addr:#x}] : {value:#x} -> {newValue:#x}")
                except subprocess.CalledProcessError:
                        logErr(f"Writing to DDR failed for address {addr:#x}")
                        sys.exit(1)

def get_ddr_addr_value(addr, length='l'):
        '''Performs DDR reads for given address ( by default reads all 64-bits / 8 bytes )'''

        if not os.getuid() == 0:
                logDebug("DDR Memory Reads require Root Privileges!")
                sys.exit(1)

        addrMap = 0x0
        value = 0xFFFFFFFF

        # versal device write using devmem
        if DEV_HOST == "versal2":
                try:
                        cmd = f"devmem2 {addr} {length}"
                        ret, stdout = execute_command(cmd)
                        logDebug(f"cmd: {cmd}")
                        logDebug(f"ret: {ret}")
                        if (ret != 0):
                                logErr(f"Reading from DDR failed: {stdout if stdout else 'NULL'}")
                                return False, False
                        value = int(stdout.strip().splitlines()[-1].split()[-1], 16)
                        addrMap = int(stdout.strip().splitlines()[-1].split()[-2].strip('():'), 16)
                        logDebug(f"DDR Read> [{addr:#x}] @ {addrMap:#x} : {value:#x}")
                except subprocess.CalledProcessError:
                        logErr(f"Reading from DDR failed for address {addr:#x}")
                        sys.exit(1)
        # sysctl device write using xsdb
        elif DEV_HOST == "sysctl":
                try:
                        cmd = f"xsdb /root/read.tcl {addr}"
                        ret, stdout = execute_command(cmd)
                        if (ret != 0):
                                logErr(f"Reading from DDR failed: {stdout if stdout else 'NULL'}")
                                return False, False
                        value = int(stdout.strip().split()[-1], 16)
                        logDebug(f"DDR Read> [{addr:#x}] : {value:#x}")
                except subprocess.CalledProcessError:
                        logErr(f"Reading from DDR failed for address {addr:#x}")
                        sys.exit(1)

        return value, addrMap