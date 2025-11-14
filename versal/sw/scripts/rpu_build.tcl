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
#
# TCL script to build the rpu standalone application.
# Usage:
#   xsct rpu_built.tcl <Workspace Path> <XSA file> <RPU Sources Path>
#

if {$argc != 3} {
	puts "Invalid Argument"
	puts "Usage: "
	puts "\t$argv0  <Workspace Path> <XSA file> <RPU Sources Path>"
	exit
}

set ws_path [lindex $argv 0]
set xsa_file [lindex $argv 1]
set rpu_src [lindex $argv 2]

puts "Building RPU application"

setws $ws_path

platform create -name vck190-hw -hw $xsa_file

domain create -name rpu_bsp -proc versal_cips_0_pspmc_0_psv_cortexr5_0 -os standalone

bsp config stdout versal_cips_0_pspmc_0_psv_sbsauart_1
bsp config stdin versal_cips_0_pspmc_0_psv_sbsauart_1

bsp setlib xilpm
bsp setlib libmetal

platform generate

app create -name rpu_app platform vck190-hw -dom rpu_bsp -os standalone -template "Empty Application"

importsources -linker-script -name rpu_app -path $rpu_src

app build -name rpu_app

