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
#include <stdio.h>
#include "xil_printf.h"
#include "xparameters.h"
#include "xipipsu.h"
#include "xil_cache.h"


#define WDTTB_FW_COUNT		10		/**< Number of clock cycles for
						  *  first window */
#define WDTTB_SW_COUNT		0x01110000	/**< Number of clock cycles for
						  *  second window */
#define WDTTB_CLK_FREQ		150000000	/** 150 Mhz */
#define WDTTB_BYTE_COUNT	154		/**< Selected byte count */
#define WDTTB_BYTE_SEGMENT	2		/**< Byte segment selected */
#define WDTTB_SST_COUNT		0x00011000      /**< Number of clock cycles for
                                                      Second sequence Timer */

#if defined(VERSAL_NET)
#define TARGET_IPI_INT_MASK    XPAR_XIPIPS_TARGET_PSX_PMC_0_CH0_MASK
#else
#define TARGET_IPI_INT_MASK    XPAR_XIPIPS_TARGET_PSV_PMC_0_CH0_MASK
#endif

#define IPI_TIMEOUT            (0xFFFFFFFFU)

/* Example defines below, update with required values */
#define ERROR_EVENT_ID                 (0x2810C000U)
#define ACTION                         (0x06U)
#define ERROR_MASK                     (0x01U)
#define HEADER(Len, ModuleId, CmdId)   ((Len << 16U) | (ModuleId << 8U) | CmdId)
#define SET_EM_ACTION_CMD_PAYLOAD_LEN  (3U)
#define EM_MODULE_ID                   (8U)
#define SET_EM_ACTION_CMD_ID           (1U)


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

XStatus WatchdogEmConfig(XIpiPsu *IpiInst)
{
	XStatus Status = XST_FAILURE;
	u32 Response;

	u32 Payload[] = {HEADER(SET_EM_ACTION_CMD_PAYLOAD_LEN, EM_MODULE_ID, SET_EM_ACTION_CMD_ID),
			ERROR_EVENT_ID, ACTION, ERROR_MASK};

	Xil_DCacheDisable();

	/* Check if there is any pending IPI in progress */
	Status = XIpiPsu_PollForAck(IpiInst, TARGET_IPI_INT_MASK, IPI_TIMEOUT);
	if (XST_SUCCESS != Status) {
		xil_printf("IPI Timeout expired\n");
		goto END;
	}
	/**
	 * Send a Message to TEST_TARGET and WAIT for ACK
	 */
	Status = XIpiPsu_WriteMessage(IpiInst, TARGET_IPI_INT_MASK, Payload,
		sizeof(Payload)/sizeof(u32), XIPIPSU_BUF_TYPE_MSG);
	if (Status != XST_SUCCESS) {
		xil_printf("Writing to IPI request buffer failed\n");
		goto END;
	}

	Status = XIpiPsu_TriggerIpi(IpiInst, TARGET_IPI_INT_MASK);
	if (Status != XST_SUCCESS) {
		xil_printf("IPI trigger failed\n");
		goto END;
	}

	/* Wait until current IPI interrupt is handled by target module */
	Status = XIpiPsu_PollForAck(IpiInst, TARGET_IPI_INT_MASK, IPI_TIMEOUT);
	if (XST_SUCCESS != Status) {
		xil_printf("IPI Timeout expired\n");
		goto END;
	}

	Status = XIpiPsu_ReadMessage(IpiInst, TARGET_IPI_INT_MASK, &Response,
		sizeof(Response)/sizeof(u32), XIPIPSU_BUF_TYPE_RESP);

	if (XST_SUCCESS != Status) {
		xil_printf("Reading from IPI response buffer failed\n");
		goto END;
	}

	Status = (XStatus)Response;

END:
	return Status;
}

