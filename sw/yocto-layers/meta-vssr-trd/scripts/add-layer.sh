#!/bin/bash
#
#*****************************************************************************
#
# Copyright (C) 2019 - 2021 Xilinx, Inc.  All rights reserved.
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
# Configure and add the meta layer to the petalinux project
#

SCRIPTPATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 ; pwd -P )"

#PLNX_ROOT=${PLNX_ROOT:-${SCRIPTPATH}/../../..}
PLNX_ROOT=${SCRIPTPATH}/../../..

#Add meta-vssr-trd layer

sed -i 's/CONFIG_USER_LAYER_0=""/CONFIG_USER_LAYER_0="${PROOT}\/project-spec\/meta-vssr-trd"\nCONFIG_USER_LAYER_1=""'/g ${PLNX_ROOT}/project-spec/configs/config

#Add Packagegroup for vssr-trd

 grep -q "^CONFIG_packagegroup-vssr-trd" ${PLNX_ROOT}/project-spec/meta-user/conf/user-rootfsconfig || echo "
CONFIG_packagegroup-vssr-trd" >> ${PLNX_ROOT}/project-spec/meta-user/conf/user-rootfsconfig

#Enable Packagegroup vssr-trd
grep -q "^CONFIG_packagegroup-vssr-trd=y" ${PLNX_ROOT}/project-spec/configs/rootfs_config || sed -i '/^# user package/!b;:a;n;/./ba;iCONFIG_packagegroup-vssr-trd=y' ${PLNX_ROOT}/project-spec/configs/rootfs_config

#Enable Auto-login
grep -q "^CONFIG_auto-login=y" ${PLNX_ROOT}/project-spec/configs/rootfs_config || sed -i '/^# Image Features/!b;:a;n;/./ba;iCONFIG_auto-login=y' ${PLNX_ROOT}/project-spec/configs/rootfs_config

unset SCRIPTPATH
unset PLNX_ROOT
