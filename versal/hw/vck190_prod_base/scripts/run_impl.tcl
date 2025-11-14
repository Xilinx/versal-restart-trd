#*****************************************************************************
#
# Copyright (C) 2019 - 2021 Xilinx, Inc. All rights reserved.
# Copyright (c) 2022 - 2025 Advanced Micro Devices, Inc.  ALL rights reserved.
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


launch_runs impl_1 -to_step write_device_image -jobs 8

wait_on_run impl_1

# CDO changes
cd vivado/versal_restart_trd.runs/impl_1
exec -ignorestderr bootgen -arch versal -image versal_restart_trd_wrapper.bif -overlay_cdo ../../../overlay/subsystem.cdo -w -o versal_restart_trd_wrapper.pdi

open_run impl_1
write_hw_platform -fixed -force -file versal_restart_trd_wrapper.xsa



cd ../../..
