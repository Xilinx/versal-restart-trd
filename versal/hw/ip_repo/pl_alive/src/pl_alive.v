//*****************************************************************************
//
// Copyright (C) 2019 - 2021 Xilinx, Inc. All rights reserved.
// Copyright (c) 2022 - 2025 Advanced Micro Devices, Inc.  ALL rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

`timescale 1ns / 1ps

module pl_alive(
    input clk,
    input ack,
    input pulse,
    output reg por = 1,
    output reg alive = 0
    );
    
    reg pulse_r;
    
    // Powers up with por = 1, and only gets reset when processor writes ack = 1
    always @(posedge clk)
        if (ack)
            por <= 0;

    
    always @(posedge clk)
        pulse_r <= pulse;
        
    always @(posedge clk)
        if (pulse & ~pulse_r)
            alive <= ~alive;
            
    
endmodule
