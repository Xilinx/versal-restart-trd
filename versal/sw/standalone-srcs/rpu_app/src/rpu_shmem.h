/******************************************************************************
*
* Copyright (C) 2019 - 2021 Xilinx, Inc. All rights reserved.
* Copyright (c) 2022 - 2025 Advanced Micro Devices, Inc.  ALL rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
******************************************************************************/


#ifndef RPU_SHMEM_H
#define RPU_SHMEM_H

#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include <metal/sys.h>
#include <metal/device.h>
#include <metal/io.h>
#include <metal/alloc.h>
#include <metal/atomic.h>
#include <metal/irq.h>
#include <errno.h>
#include <metal/cpu.h>
#include <xil_printf.h>
#include "xuartpsv.h"

/* Shared memory offsets */
#define SHM_DEMO_CNTRL_OFFSET       0x0
#define SHM_RX_AVAIL_OFFSET        0x04
#define SHM_RX_USED_OFFSET         0x08
#define SHM_TX_AVAIL_OFFSET        0x0C
#define SHM_TX_USED_OFFSET         0x10
#define SHM_RX_BUFFER_OFFSET       0x14
#define SHM_TX_BUFFER_OFFSET       0x400


#define SHM_BASE		0x3E400000
#define SHM_SIZE		0x00100000

/* Devices names */
#define BUS_NAME        "generic"
#define SHM_DEV_NAME    "comm.shm"


#define DEMO_STATUS_IDLE         0x0
#define DEMO_STATUS_START        0x1 /* Status value to indicate demo start */


#define LPRINTF(format, ...) \
  xil_printf("\r\nSERVER> " format, ##__VA_ARGS__)

#define LPERROR(format, ...) xil_printf("ERROR: " format, ##__VA_ARGS__)

int rpu_load_message(int size);

int rpu_send_message(char* message);

char* rpu_read_message();

int rpu_cleanup();

int rpu_clear_message();

int rpu_shmem_setup();

int rpu_finish();

#endif
