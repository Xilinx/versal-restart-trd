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
set_property    PACKAGE_PIN L33         [get_ports "UART_1_txd"]  ; # Bank 306  VCC1V8       IO_L3P_306      
set_property    IOSTANDARD LVCMOS18     [get_ports "UART_1_txd"]  ; 
set_property    PACKAGE_PIN K33         [get_ports "UART_1_rxd"]  ; # Bank 306  VCC1V8       IO_L3N_306      
set_property    IOSTANDARD LVCMOS18     [get_ports "UART_1_rxd"]  ; 

