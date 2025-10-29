#!/usr/bin/python3

#*****************************************************************************
#
# Copyright (C) 2019 - 2021 Xilinx, Inc.  All rights reserved.
# Copyright (c) 2022 - 2023 Advanced Micro Devices, Inc.  All rights reserved.
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
#
#******************************************************************************
#
# Python script to test restart use cases without jupyter notebook.
#

import time
import vssr_trd as trd

d_target = {0: 'APU', 1: 'RPU'}
d_action = {0: 'Subsystem Restart', 1: 'System Restart', 2: 'Healthy Boot Test', 4: 'WDT Recovery Test', 5:'Image Store'}
d_operation = {'1':[0,0],
               '2':[0,1],
               '3':[0,2],
               '4':[0,4],
               '5':[1,0],
               '6':[1,1],
               '7':[1,2],
               '8':[1,4],
               '9':[1,5] }

def getAction():
    print("\nVersal Restart TRD Testing. Choose the Test:\n")
    print("1. APU: Subsystem Restart")
    print("2. APU: System Restart")
    print("3. APU: Healthy Boot Test")
    print("4. APU: WDT Recovery")
    print("5. RPU: Subsystem Restart")
    print("6. RPU: System Restart")
    print("7. RPU: Healthy Boot Test")
    print("8. RPU: WDT Recovery")
    print("9. APU: Image Store")
    print("0. Exit\n\n")
    choice = input("Enter your choice: ")

    return choice


choice = getAction()

while choice != '0':
    if choice in d_operation:
        op = d_operation[choice]
        Target = op[0]
        Action = op[1]
        print (d_target[Target] + " will perform " + d_action[Action])
        trd.init()
        if Target == 0 and Action == 2:
            print("APU will perform Subsystem Restart.Enter u-boot and wait for 120 seconds for Healthy Boot Test")
            for i in range(5,0,-1):
                print(f"{i}", end="\r", flush=True)
                time.sleep(1)
        trd.SetControl(Target,Action)
        trd.deinit()
    else:
        print("Invalid choice, please choose again\n")

    time.sleep(2)
    choice = getAction()

print("Good bye")


