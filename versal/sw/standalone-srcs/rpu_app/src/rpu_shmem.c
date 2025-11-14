/******************************************************************************
*
* Copyright (C) 2019 - 2021 Xilinx, Inc. All rights reserved.
* Copyright (c) 2022 - 2025 Advanced Micro Devices, Inc. ALL rights reserved.
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


#include "rpu_shmem.h"

struct metal_device *shm_dev;
struct metal_io_region *io;

void *data = NULL;

unsigned int rx_count;
unsigned int len;

int rpu_load_message(int size)
{
	int ret = 0;
	rx_count = 0;

	/* clear demo status value */
	metal_io_write32(io, SHM_DEMO_CNTRL_OFFSET, 0);

	/* allocate memory for receiving data */
	if (!data){
		data = metal_allocate_memory(size+1);
		if (!data) {
				LPERROR("Failed to allocate memory.\r\n");
				return -1;
			}
	}
	/* Read the message data */
	ret = metal_io_block_read(io,
			SHM_RX_BUFFER_OFFSET,
			data, size + 1);
	*((char*)data + size) = 0;
	return ret;
}

int rpu_send_message(char* message){
		int ret = 0;
		ret = metal_io_block_write(io,
			SHM_TX_BUFFER_OFFSET,
			(void*)message, strlen(message));
		if (ret < 0){
			LPERROR("Unable to metal_io_block_write()\n");
			return ret;
		}
		return ret;

}

int rpu_clear_message(){
	return rpu_send_message("  ");
}

int rpu_cleanup(){
	if (data){
		metal_free_memory(data);
		data = NULL;
	}
	return 0;
}

char* rpu_read_message(){
	if (data){
		return (char*)(data);
	}
	else{
		return "No Message";
	}
}


int rpu_shmem_setup(){
	struct metal_init_params metal_param = METAL_INIT_DEFAULTS;
	metal_init(&metal_param);

	int ret = 0;
	data = NULL;
	static const metal_phys_addr_t shm_phys_addr = SHM_BASE;
	static struct metal_device shm = {
		.name = SHM_DEV_NAME, /* device name */
		.bus = NULL, /* device bus */
		.num_regions = 1, /* number of regions on device */
	{
	{
		.virt = (void*) SHM_BASE, /* virtual address */
		.physmap = &shm_phys_addr, /* physical address */
		.size = SHM_SIZE, /* size of region */
		.page_shift = (sizeof(metal_phys_addr_t) << 3), /* page shift */
		.page_mask = (unsigned long)(-1), /* page mask */
		.mem_flags = NORM_SHARED_NCACHE | PRIV_RW_USER_RW, /* memory flags */
		.ops = {NULL}, /* user defined memory operations */
	}
	},
		.node = {NULL}, /* node to point to device in list of nodes on bus */
		.irq_num = 0, /* Number of IRQs per device. This is 0 because there are no
		interrupts we want to use for this device.*/
		.irq_info = NULL, /* IRQ info. This is NULL because we are not using this device
		for interrupts. */
	};
	/* Get shared memory device IO region */
	ret = metal_register_generic_device(&shm);
	ret = metal_device_open(BUS_NAME, SHM_DEV_NAME, &shm_dev);
	if (ret) {
		LPERROR("Failed to open device %s.\n", SHM_DEV_NAME);
		return ret;
	}
	if (!shm_dev) {
		ret = -ENODEV;
		return ret;
	}
	io = metal_device_io_region(shm_dev, 0);
	if (!io) {
		LPERROR("Failed to map io region for %s.\n", shm_dev->name);
		ret = -ENODEV;
		return ret;
	}
	ret = metal_io_block_write(io, SHM_RX_BUFFER_OFFSET, " ", strlen(" "));
	ret = metal_io_block_write(io, SHM_TX_BUFFER_OFFSET, " ", strlen(" "));

	return ret;
}

int rpu_finish(){
	if (shm_dev){
		metal_device_close(shm_dev);
	}
	metal_finish();
	return 0;
}
