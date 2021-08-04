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

#include "xwdttb.h"

#define WDTTB_FW_COUNT		10		/**< Number of clock cycles for
						  *  first window */
#define WDTTB_SW_COUNT		0x01110000	/**< Number of clock cycles for
						  *  second window */
#define WDTTB_CLK_FREQ		150000000	/** 150 Mhz */
#define WDTTB_BYTE_COUNT	154		/**< Selected byte count */
#define WDTTB_BYTE_SEGMENT	2		/**< Byte segment selected */
#define WDTTB_SST_COUNT		0x00011000      /**< Number of clock cycles for
                                                      Second sequence Timer */
static XWdtTb WatchdogTimebase;

XStatus WatchdogInit(const u32 DeviceId, const u32 TimeOut)
{
	int Status;
	XWdtTb_Config *Config;

	/*
	 * Initialize the WDTTB driver so that it's ready to use look up
	 * configuration in the config table, then initialize it.
	 */
	Config = XWdtTb_LookupConfig(DeviceId);
	if (NULL == Config) {
		return XST_FAILURE;
	}

	/*
	 * Initialize the watchdog timer and timebase driver so that
	 * it is ready to use.
	 */
	Status = XWdtTb_CfgInitialize(&WatchdogTimebase, Config,
			Config->BaseAddr);
	if (Status != XST_SUCCESS) {
		return Status;
	}

	if(!WatchdogTimebase.Config.IsPl) {
		/*Enable Window Watchdog Feature in WWDT */
		XWdtTb_ConfigureWDTMode(&WatchdogTimebase, XWT_WWDT);
	}

	/* Configure first and second window */
	XWdtTb_SetWindowCount(&WatchdogTimebase, WDTTB_FW_COUNT,
		TimeOut * WDTTB_CLK_FREQ);

	/* Set interrupt position */
	XWdtTb_SetByteCount(&WatchdogTimebase, WDTTB_BYTE_COUNT);
	XWdtTb_SetByteSegment(&WatchdogTimebase, WDTTB_BYTE_SEGMENT);

	/*
	 * Start the watchdog timer, the timebase is automatically reset
	 * when this occurs.
	 */
	XWdtTb_Start(&WatchdogTimebase);
	return Status;
}

XStatus WatchdogKeepAlive(void)
{
	XWdtTb_SetRegSpaceAccessMode(&WatchdogTimebase, 1);
	XWdtTb_RestartWdt(&WatchdogTimebase);
	return XST_SUCCESS;
}

