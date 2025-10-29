/******************************************************************************
*
* Copyright (C) 2019 - 2021 Xilinx, Inc.  All rights reserved.
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

#include "apu-shmem.h"

#define DEAD 0
#define ALIVE 1

struct metal_device *device;
struct metal_io_region *io;

void *tx_data;
void *rx_data;
unsigned int tx_count;
unsigned int rx_count;
unsigned int data_len;
struct msg_hdr_s *msg_hdr;

char alive[] = "Alive0";

//Commands
char ssr[] = "Subsystem Restart";
char sysr[] = "System Restart";
char wdt[] = "Kill Watchdog";
char hlthy[] = "Do Healthy Boot Test";


static inline void dump_buffer(void *buf, unsigned int len)
{
	unsigned int i;
	unsigned char *tmp = (unsigned char *)buf;

	for (i = 0; i < len; i++) {
		printf(" %02x", *(tmp++));
		if (!(i % 20))
			printf("\n");
	}
	printf("\n");
}

char* apu_read_message(){
	if (rx_data){
		return (char*)(rx_data);
	}
	else{
		return "No Message";
	}

}

int apu_receive(int len){
	int ret;
	rx_count = 0;
	int x = 0;
	data_len = len + 1;
	metal_io_write32(io, SHM_RX_AVAIL_OFFSET, 0);
	rx_count++;
	/* New RX data is available, allocate buffer to received data */
	if (!rx_data){
		rx_data = metal_allocate_memory(data_len);
		if (!rx_data) {
			LPERROR("Failed to allocate memory\n");
			ret = -1;
			return ret;
		}
	}
	/* read data from the shared memory*/
	metal_io_block_read(io, SHM_RX_BUFFER_OFFSET,
		 rx_data, data_len);
	if (ret < 0){
		LPERROR("Unable to metal_io_block_read()\n");
		return ret;
	}
	/* verify the received data */
	ret = 0;
	if (ret) {
		LPERROR("Received data verification failed.\n");
		LPRINTF("Expected:");
		dump_buffer(tx_data, data_len);
		LPRINTF("Actual:");
		dump_buffer(rx_data, data_len);
	} else {
		*((char*)rx_data + len) = 0;
	}
	/* Notify the remote the demo has finished. */
	metal_io_write32(io, SHM_DEMO_CNTRL_OFFSET, DEMO_STATUS_IDLE);
	return ret;
}
int apu_send(char* message){
	tx_count = 0;
	int ret;

	/* clear demo status value */
	metal_io_write32(io, SHM_DEMO_CNTRL_OFFSET, 0);
	/* Clear TX/RX avail */
	metal_io_write32(io, SHM_TX_AVAIL_OFFSET, 0);

	// /* Notify the remote the demo starts */
	metal_io_write32(io, SHM_DEMO_CNTRL_OFFSET, DEMO_STATUS_START);

	/* preparing data to send */
	data_len = strlen(message) + 1;
	if (!tx_data){
		tx_data = metal_allocate_memory(data_len);
		if (!tx_data) {
			LPERROR("Failed to allocate memory.\n");
			ret = -1;
			return ret;
		}
	}
	msg_hdr = (struct msg_hdr_s *)tx_data;
	msg_hdr->index = tx_count;
	msg_hdr->len = strlen(message) + 1;
	sprintf(tx_data, "%s", message);

	/* write data to the shared memory*/
	ret = metal_io_block_write(io, SHM_TX_BUFFER_OFFSET,
		tx_data, data_len + 1);
	if (ret < 0){
		LPERROR("Unable to metal_io_block_write()\n");
		return ret;
	}
	/* Increase number of buffers available to notify the remote */
	tx_count++;
	metal_io_write32(io, SHM_TX_AVAIL_OFFSET, tx_count);

	/* Notify the remote the demo starts */
	metal_io_write32(io, SHM_DEMO_CNTRL_OFFSET, DEMO_STATUS_START);
	return ret;

}

int apu_cleanup(){
	if (tx_data){
		metal_free_memory(tx_data);
		tx_data = NULL;
	}
	if (rx_data){
		metal_free_memory(rx_data);
		rx_data = NULL;
	}
	return 0;
}

int apu_clear_message(){
	return apu_send(" ");
}


int apu_setup()
{
	struct metal_init_params metal_param = METAL_INIT_DEFAULTS;
	metal_param.log_level = METAL_LOG_ERROR;
	metal_init(&metal_param);

	device = NULL;
	io = NULL;

	tx_data = NULL;
	rx_data = NULL;

	int ret = 0;


	/* Open the shared memory device */
	ret = metal_device_open(BUS_NAME, SHM_DEV_NAME, &device);
	if (ret) {
		LPERROR("Failed to open device %s.\n", SHM_DEV_NAME);
		return ret;
	}

	/* get shared memory device IO region */
	io = metal_device_io_region(device, 0);
	if (!io) {
		LPERROR("Failed to get io region for %s.\n", device->name);
		ret = -ENODEV;
		return ret;
	}

	return ret;
}

int apu_finish(){
	if (device)
		metal_device_close(device);
	metal_finish();
	return 0;
}

int request_rpu_command(char* command){
	apu_send(command);
	usleep(500 * 1000);
	apu_clear_message();
	apu_cleanup();
	return 0;
}

int rpu_is_alive(){
	int status = DEAD;
	int msg_size = strlen(alive);
	apu_receive(msg_size);
	char *msg = apu_read_message();
	if (strncmp(msg, alive, msg_size - 1) == 0) {
		if (msg[msg_size - 1] != alive[msg_size - 1]) {
			status = ALIVE;
			alive[msg_size - 1] = msg[msg_size - 1];
		}
	}
	apu_cleanup();
	return status;
}


