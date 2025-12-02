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

# Baremetal app name
APP = "hello-world"

FHW_DEPENDS = ""

FHW_MCDEPENDS = "mc::${MACHINE}-cortexr52-1-baremetal:${APP}:do_deploy"
DEPENDS:remove = "${APP}"
do_compile[mcdepends] += "${FHW_MCDEPENDS}"

FHW_DEPLOY_DIR = "${TMPDIR}-${MACHINE}-cortexr52-1-baremetal/deploy/images/${MACHINE}"
BIF_PARTITION_ATTR:append = " ${APP}"

# over-write with custom Subsystem Name
BIF_PARTITION_NAME[0x1c000007] ?= "rpu_subsys"
# over-write r52 core-cluster in .bif file
BIF_PARTITION_ATTR[hello-world] = "destination_cpu=r52-1"
# over-write rpu app .elf in .bif file
BIF_PARTITION_IMAGE[hello-world] = "${FHW_DEPLOY_DIR}/${APP}-${MACHINE}-${MACHINE}-cortexr52-1-baremetal.elf"
# over-write RPU with custom Subsystem ID
BIF_PARTITION_ID[hello-world] = "0x1c000007"
