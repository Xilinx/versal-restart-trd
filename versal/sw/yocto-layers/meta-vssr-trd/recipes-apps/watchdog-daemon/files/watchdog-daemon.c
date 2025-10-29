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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/watchdog.h>

#define TIMEOUT		20
#define KICK_DELAY	5

#define WDT_FILE	"/dev/watchdog"

int main(void)
{
	int ret;
	int fd;
	int timeout = TIMEOUT;
	int delay = KICK_DELAY;
	int read_back=0;

	struct watchdog_info info;

	fd = open(WDT_FILE, O_WRONLY);

	if (fd == -1) {
		if (errno == ENOENT)
			printf("Watchdog device (%s) not found.\n", WDT_FILE);
		else if (errno == EACCES)
			printf("Run watchdog as root.\n");
		else
			printf("Watchdog device open failed %s\n",
				strerror(errno));
		exit(-1);
	}

	/*
	 * Validate that `file` is a watchdog device
	 */
	ret = ioctl(fd, WDIOC_GETSUPPORT, &info);
	if (ret) {
		printf("WDIOC_GETSUPPORT error '%s'\n", strerror(errno));
		close(fd);
		exit(ret);
	}

	ret = ioctl(fd, WDIOC_SETTIMEOUT, &timeout);
	if (!ret)
		printf("Watchdog timeout set to %u seconds.\n", timeout);
	else
		printf("WDIOC_SETTIMEOUT error '%s'\n", strerror(errno));

	/* read back */
	ret = ioctl(fd, WDIOC_GETTIMEOUT, &read_back);
	if (!ret)
		printf("WDIOC_GETTIMEOUT returns %u seconds.\n", read_back);
	else
		printf("WDIOC_GETTIMEOUT error '%s'\n", strerror(errno));

	if (delay) {
		do{
			sleep(delay);
			ret = ioctl(fd, WDIOC_KEEPALIVE, NULL);
		}while (1);
	}

	close(fd);

    return 0;
}
