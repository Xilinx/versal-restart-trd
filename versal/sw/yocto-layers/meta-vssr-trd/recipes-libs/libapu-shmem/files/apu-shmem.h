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

#ifndef APU_SHMEM_H
#define APU_SHMEM_H
#include <metal/atomic.h>
#ifdef __cplusplus
extern "C"{
#endif
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <metal/device.h>
#include <metal/io.h>
#include <metal/alloc.h>
#include <metal/irq.h>
#include <metal/cpu.h>

/* Shared memory offsets */
#define SHM_DEMO_CNTRL_OFFSET      0x0
#define SHM_TX_AVAIL_OFFSET        0x04
#define SHM_RX_AVAIL_OFFSET        0x0C
#define SHM_TX_BUFFER_OFFSET       0x14
#define SHM_RX_BUFFER_OFFSET       0x400

#define SHM_BUFFER_SIZE          0x100

#define DEMO_STATUS_IDLE         0x0
#define DEMO_STATUS_START        0x1 /* Status value to indicate demo start */


#define BUS_NAME        "platform"
#define SHM_DEV_NAME    "3e400000.shm"
#define LPRINTF(format, ...) \
  printf("APU> " format, ##__VA_ARGS__)

#define LPERROR(format, ...) LPRINTF("ERROR: " format, ##__VA_ARGS__)

 struct msg_hdr_s {
	uint32_t index;
	uint32_t len;
};


static inline void dump_buffer(void *buf, unsigned int len);

static inline void print_demo(char *name);

char* apu_read_message();

int apu_receive(int len);

int apu_send(char* message);

int apu_cleanup();


int apu_finish();

int apu_clear_message();

int apu_setup();

int request_rpu_command(char* command);

int rpu_is_alive();

#ifdef __cplusplus
}
#endif
#endif
