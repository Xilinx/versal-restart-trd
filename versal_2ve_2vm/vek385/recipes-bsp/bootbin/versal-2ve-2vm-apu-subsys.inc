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

# Specify BIF common attribute for FSBL
BIF_COMMON_ATTR ?= ""

# Specify BIF optional attributes
BIF_OPTIONAL_DATA ?= ""

# Specify BIF partition attributes required for BOOT.bin
BIF_FSBL_ATTR       ??= "base-pdi plmfw"
BIF_ATF_ATTR        ??= "arm-trusted-firmware"
BIF_OPTEE_ATTR      ??= "${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'optee-os', '', d)}"
BIF_ASU_ATTR        ??= ""
BIF_DEVICETREE_ATTR ??= "device-tree"
BIF_SSBL_ATTR       ??= "u-boot-xlnx"
BIF_PARTITION_ATTR  ??= "${BIF_FSBL_ATTR} ${BIF_ASU_ATTR} ${BIF_DEVICETREE_ATTR} ${BIF_ATF_ATTR} ${BIF_OPTEE_ATTR} ${BIF_SSBL_ATTR}"

# .bif file Image section name and Subsystem ID ( for APU running Linux )
BIF_PARTITION_NAME[0x1c000006] ?= "apu_subsys"
# Custom Subsystem ID for Device Tree
BIF_PARTITION_ID[device-tree] = "0x1c000006"
# Custom Subsystem ID for u-boot
BIF_PARTITION_ID[u-boot-xlnx] = "0x1c000006"
# Custom Subsystem ID for TF-A
BIF_PARTITION_ID[arm-trusted-firmware] = "0x1c000006"
# Custom Subsystem ID for OPTEE
BIF_PARTITION_ID[optee-os] = "0x1c000006"
