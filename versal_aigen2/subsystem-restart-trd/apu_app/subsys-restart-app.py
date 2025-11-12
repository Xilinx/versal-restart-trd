#!/usr/bin/python3

###############################################################################
# Copyright (C) 2025 Advanced Micro Devices, Inc. All Rights Reserved.
# SPDX-License-Identifier: MIT
###############################################################################

#
# Python application to exercise TSSR TRD
#

import sys
import time

import utility as util
import importlib

srd = importlib.import_module("subsys-restart-funcs")

ApuTrdActions = {
        0x0 : ["echo subsystem > /sys/devices/platform/firmware\\:versal2-firmware/shutdown_scope", "reboot"],
        0x1 : ["echo system > /sys/devices/platform/firmware\\:versal2-firmware/shutdown_scope", "reboot"],
        0x2 : ["echo system > /sys/devices/platform/firmware\\:versal2-firmware/shutdown_scope", "reboot"]
}

def app():
        '''Main application for TRD'''

        # check for any APU boots (subsystem/system)
        ddrStatusValue, _ = util.get_ddr_addr_value(srd.TssrDDRRegions['APU']['status'], 'w')
        slaveId = (ddrStatusValue & 0xF)
        # check whether APU was booted
        if (slaveId & 0x1) == 0x1:
                # check whether previous APU action had reboot or not
                isSlave = (ddrStatusValue >> 28) & 0x1
                isAlive = (ddrStatusValue >> 30) & 0x1
                if ((isAlive & 0x1) == 0x0) and (isSlave & 0x1):
                        # send another acknowledgement indicating previous action is completed and that slave is now alive
                        util.set_ddr_addr_value(srd.TssrDDRRegions['APU']['status'], srd.DDR_ADDR_32BITMASK, (0x1) | (0x0 << 4) | (srd.SLAVE_ACK_DONE << 8) | (0x1 << 28) | (0x1 << 30), 'w')
                        time.sleep(15)   # wait for the ack to be received and read

        # reset action & status registers on initial run
        util.set_ddr_addr_value(srd.TssrDDRRegions['APU']['action'], srd.DDR_ADDR_32BITMASK, srd.DDR_ADDR_32BITMASK, 'w')
        util.set_ddr_addr_value(srd.TssrDDRRegions['APU']['status'], srd.DDR_ADDR_32BITMASK, srd.DDR_ADDR_32BITMASK, 'w')

        while (True):
                ddrActionValue, _ = util.get_ddr_addr_value(srd.TssrDDRRegions['APU']['action'], 'w')

                # don't care - subsystem restart application in idle state
                if srd.DDR_ADDR_32BITMASK == ddrActionValue:
                        pass
                # check whether action is intended for APU
                elif (ddrActionValue & 0x1) == 0x1:
                        coreId = (ddrActionValue >> 8) & 0xFF
                        actionId = (ddrActionValue >> 12) & 0xFF
                        util.logDebug(f"APU> Core Id: {coreId} Action: {actionId}\n")

                        # set slave acknowledgement
                        util.set_ddr_addr_value(srd.TssrDDRRegions['APU']['status'], srd.DDR_ADDR_32BITMASK, (0x1) | (coreId << 4) | (srd.SLAVE_ACK_OK << 8) | (0x1 << 28) | (0x0 << 30), 'w')
                        for cmd in ApuTrdActions[actionId]:
                                util.execute_command(cmd)

                time.sleep(0.5)

if __name__ == "__main__":
        if (False == util.sanity_check()):
                util.logErr(f"Sanity check failed for power-states application running on {util.DEV_HOST}")
                sys.exit(1)

        app()