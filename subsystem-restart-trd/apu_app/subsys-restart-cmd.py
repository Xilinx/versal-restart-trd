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
# Python application running on APU (linux) to exercise Versal Subsystem Restart TRD
#

import os
import sys
import shutil
import time
import importlib

import utility as util
srd = importlib.import_module("subsys-restart-funcs")

def app():
        '''main application entry point'''

        if util.DEV_HOST == "sysctl":
                # initialize necessary jtag pins on sysctl to access targets on xsdb
                jtagGpioInitCmd = "sc_app -c setJTAGselect -t SC"       # sc_app version >= 1.25
                util.execute_command(jtagGpioInitCmd)

                saveWS = os.getcwd()
                os.chdir("/root")
                # write .tcl scripts to read/write DDR memory using xsdb
                with open('read.tcl', 'w') as f:
                        f.write('# get address from argument\n')
                        f.write('set reg_addr [lindex $argv 0]\n\n')
                        f.write('# connect to hardware server\n')
                        f.write('connect\n\n')
                        f.write('# filter and set versal2 target\n')
                        f.write('targets -set -filter {name =~ "Versal*"}\n\n')
                        f.write('# read the address\n')
                        f.write('puts [mrd -force $reg_addr]\n')

                with open('write.tcl', 'w') as f:
                        f.write('# get register address and value\n')
                        f.write('set reg_addr [lindex $argv 0]\n')
                        f.write('set reg_value [lindex $argv 1]\n\n')
                        f.write('# connect to hardware server\n')
                        f.write('connect\n\n')
                        f.write('# set the target\n')
                        f.write('targets -set -filter {name =~ "Versal*"}\n\n')
                        f.write('# write the address\n')
                        f.write('puts [mwr -force $reg_addr $reg_value]\n')
                os.chdir(saveWS)

        selectedChoice = srd.get_trd_options()

        while (selectedChoice != "0"):
                coreId = srd.TssrTrdChoices[selectedChoice]["core-id"]
                actionId = srd.TssrTrdChoices[selectedChoice]["action"]
                slave = ""

                if "1" == selectedChoice:
                        util.logPrint(f"APU> {srd.TssrTrdChoices[selectedChoice]['op-name']} - {srd.TssrTrdChoices[selectedChoice]['op-desc']}")
                        util.logDebug(f"Write @ DDR Address {srd.TssrDDRRegions["APU"]["action"]:#x} with value 0x1ULL!")
                        slave = "APU"
                        time.sleep(5)
                        util.set_ddr_addr_value(srd.TssrDDRRegions["APU"]["action"], srd.DDR_ADDR_32BITMASK, 0x1 | (coreId << 4) | (actionId << 12), 'w')
                elif "2" == selectedChoice:
                        util.logPrint(f"APU> {srd.TssrTrdChoices[selectedChoice]['op-name']} - {srd.TssrTrdChoices[selectedChoice]['op-desc']}")
                        util.logDebug(f"Write @ DDR Address {srd.TssrDDRRegions["APU"]["action"]:#x} with value 0x1001ULL!")
                        slave = "APU"
                        time.sleep(5)
                        util.set_ddr_addr_value(srd.TssrDDRRegions["APU"]["action"], srd.DDR_ADDR_32BITMASK, 0x1 | (coreId << 4) | (actionId << 12), 'w')
                elif "3" == selectedChoice:
                        util.logDebug(f"Write @ DDR Address {srd.TssrDDRRegions["APU"]["action"]:#x} with value 0x0000ULL!")
                        slave = "APU"
                        time.sleep(5)
                        util.set_ddr_addr_value(srd.TssrDDRRegions["APU"]["action"], srd.DDR_ADDR_32BITMASK, 0x1 | (coreId << 4) | (actionId << 12), 'w')

                # wait for slave to accept and generate response
                time.sleep(10)

                while (True):
                        ack, isSlave, isAlive = srd.get_slave_response(slave)
                        if (ack == srd.SLAVE_ACK_OK):
                                util.logInfo(f"Slave executing the task: ACK={ack:#x}, isAlive={isAlive}")
                                print()

                                # wait for slave to reboot and come back alive
                                if ((actionId == srd.TssrTrdActions["ACTION_SYSTEM_RESTART"]) or (actionId == srd.TssrTrdActions["ACTION_SUBSYSTEM_RESTART"])):
                                        time.sleep(40)  # wait for slave to complete boot
                                        while (True):
                                                ack, isSlave, isAlive = srd.get_slave_response(slave)
                                                if ((isAlive) and (ack == srd.SLAVE_ACK_DONE)):
                                                        util.logDebug(f"Slave completed executing: ACK={ack:#x}, isAlive={isAlive}")
                                                        util.logOut(f"Slave is back alive after {srd.TssrTrdChoices[selectedChoice]['op-name']}")
                                                        print()
                                                        break
                                                util.logDebug(f"Waiting for Slave to come back alive: ACK={ack:#x}, isSlave={isSlave}, isAlive={isAlive}")
                                                time.sleep(0.5)

                                break
                        util.logDebug(f"Status Address: ACK={ack:#x}, isSlave={isSlave}, isAlive={isAlive}")
                        time.sleep(0.5)

                selectedChoice = srd.get_trd_options()

        print(util.fmt["GREEN"]("Application Closed!"))

if __name__ == "__main__":

        if '-D' in sys.argv:
                util.LOG_DEBUG = 1

        if shutil.which("sc_app") == None:
                util.DEV_HOST = "versal2"
                util.logInfo("Package running on Versal2 device")
        else:
                util.DEV_HOST = "sysctl"
                util.logInfo("Package running on System Controller")

        if (False == util.sanity_check()):
                util.logErr(f"Sanity check failed for subsystem restart application running on {util.DEV_HOST}")
                sys.exit(1)

        app()