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
# Python Module has all the handlers needed for Subsystem Restart TRD
#

import utility as util

DEV_CONF = {}           # DEV_CONF is device specific configuration which gets populated when building .rpm package

try:
    DDR_RESERVED_ADDR1 = int(DEV_CONF["RESERVED_DDR_BASE_ADDRESS"], 16)         # Action register base address
except KeyError:
    raise RuntimeError(
        "Application not configured properly."
        "This application must be installed via RPM package."
        "Abort!"
    )

DDR_RESERVED_ADDR2      = DDR_RESERVED_ADDR1 + 0x4                              # Status register base address
DDR_MESG_HEADER_ADDR    = DDR_RESERVED_ADDR1 + 0x40
DDR_MESG_BUFFER_ADDR    = DDR_RESERVED_ADDR1 + 0x48

DDR_ADDR_32BITMASK      = int('0xFFFFFFFF', 16)
DDR_ADDR_64BITMASK      = int('0xFFFFFFFFFFFFFFFF', 16)
SLAVE_ACK_OK            = 0x55
SLAVE_ACK_DONE          = 0xAA

TssrDDRRegions = {
        "RPU" : {
                "action" : DDR_RESERVED_ADDR1 + 0x0,
                "status" : DDR_RESERVED_ADDR2 + 0x0,
                "msgHeader" : DDR_MESG_HEADER_ADDR,
                "msgBuffer" : DDR_MESG_BUFFER_ADDR
        },
        "APU" : {
                "action" : DDR_RESERVED_ADDR1 + 0x1000,
                "status" : DDR_RESERVED_ADDR2 + 0x1000,
                "msgHeader" : DDR_MESG_HEADER_ADDR + 0x1000,
                "msgBuffer" : DDR_MESG_BUFFER_ADDR + 0x1000
        }
}
'''
TssrDDRRegions = {
        "<agent>" : {
                "action" : 0x...,
                "status" : 0x...,
                "msgHeader" : 0x...,
                "msgBuffer" : 0x...
        },
        .
        .
        .
}
'''

TssrTrdCores = {
        "0.0": 0x0,
        "0.1": 0x1,
        "1.0": 0x2,
        "1.1": 0x3,
        "2.0": 0x4,
        "2.1": 0x5,
        "3.0": 0x6,
        "3.1": 0x7,
        "4.0": 0x8,
        "4.1": 0x9
}
'''
TssrTrdCores = {
        "<cluster>.<core>": <core-id>,
        .
        .
        .
}
'''

TssrTrdActions = {
        "ACTION_SUBSYSTEM_RESTART"      : 0x0,
        "ACTION_SYSTEM_RESTART"         : 0x1,
        "ACTION_HEALTHY_BOOT_TEST"      : 0x2,
        "ACTION_WATCHDOG_RECOVERY"      : 0x3,
        "ACTION_IMAGE_STORE_BOOT"       : 0x4
}
'''
TrdActions = {
        <action-id>: "<Action Description>",
        .
        .
        .
}
'''

TssrTrdChoices = {
        "1" : {
                "core-id"     : TssrTrdCores["0.0"],
                "op-name"     : "APU Subsystem Restart",
                "op-desc"     : "APU performs a self-subsystem restart. APU talks to PLM to perform subsystem shutdown scope",
                "action"      : TssrTrdActions["ACTION_SUBSYSTEM_RESTART"]
        },
        "2" : {
                "core-id"     : TssrTrdCores["0.0"],
                "op-name"     : "APU System Restart",
                "op-desc"     : "APU performs a system restart. APU talks to PLM to perform system shutdown scope",
                "action"      : TssrTrdActions["ACTION_SYSTEM_RESTART"]
        },
        "3" : {
                "core-id"     : TssrTrdCores["0.0"],
                "op-name"     : "APU Healthy Boot Recovery",
                "op-desc"     : "APU fails to boot, triggering PLM to perform system wide restart as part of Healthy Boot Recovery",
                "action"      : TssrTrdActions["ACTION_HEALTHY_BOOT_TEST"]
        },
        "0" : {
                "core-id"     : "NaN",
                "op-name"     : "Exit",
                "op-desc"     : "Close TSSR TRD App!",
                "action"      : "Goodbye"
        }
}
'''
TssrTrdChoices = {
        <op-id> : {
                "master-core" : "<core-id>",
                "slave-core"  : "<core-id>",
                "op-name"     : "...",
                "op-desc"     : "..."
        }
        .
        .
        .
}
'''

def get_trd_options():
        '''Prints TSSR TRD options in Table Format and returns selected choice'''

        print()
        optionTableHeader = ["ID", "Name", "Description"]
        optionTableData = []
        for op_id, op_info in TssrTrdChoices.items():
                optionTableData.append([op_id, op_info['op-name'], op_info['op-desc']])
        util.pretty_table_print(optionTableHeader, optionTableData)

        selectedID = input("Select an operation ID: ")
        while(selectedID.lstrip() not in TssrTrdChoices):
                util.logErr(f"Invalid operation ID: {selectedID}")
                selectedID = input("Select an operation ID: ")

        print("\n")
        return selectedID.lstrip()

def get_slave_response(slave:str):
        '''get acknowledgment from the slave'''
        status, _ = util.get_ddr_addr_value(TssrDDRRegions[slave]["status"], 'w')
        ack = (status >> 8) & 0xFF
        isSlave = (status >> 28) & 0x1
        isAlive = (status >> 30) & 0x1

        return ack, isSlave, isAlive