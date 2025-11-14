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

set my_board [get_board_parts xilinx.com:vck190:part0:* -latest_file_version]
create_project -force vivado/versal_restart_trd . -part [get_property PART_NAME [get_board_parts $my_board]]
set_property board_part $my_board [current_project]
set_property  ip_repo_paths  ../ip_repo [current_project]
update_ip_catalog


source scripts/pl_subsystem.tcl
source scripts/subsystem_restart.tcl

set bdwrapper [make_wrapper -files [get_files versal_restart_trd.bd] -top]
add_files -norecurse $bdwrapper
update_compile_order -fileset sources_1

add_files -fileset constrs_1 -norecurse xdc/subsystem_design_top.xdc

validate_bd_design
save_bd_design



