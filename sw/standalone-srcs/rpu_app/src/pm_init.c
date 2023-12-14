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

#include "pm_api_sys.h"
#include "ipi.h"
#include "gic_setup.h"
#include "pm_init.h"

XStatus PmInit(XScuGic *const GicInst, XIpiPsu *const IpiInst, u32 FullBoot)
{
	XPm_Dbg("%s Started", __func__);
        int Status;

	/* GIC Initialize */
	if (NULL != GicInst) {
		Status = GicSetupInterruptSystem(GicInst);
		if (Status != XST_SUCCESS) {
			XPm_Dbg("GicSetupInterruptSystem() failed with error: %d\r\n", Status);
			goto done;
		}
	}

	/* IPI Initialize */
        Status = IpiInit(GicInst, IpiInst);
        if (XST_SUCCESS != Status) {
                XPm_Dbg("IpiInit() failed with error: %d\r\n", Status);
                goto done;
        }

	/* XilPM Initialize */
        Status = XPm_InitXilpm(IpiInst);
        if (XST_SUCCESS != Status) {
                XPm_Dbg("XPm_InitXilpm() failed with error: %d\r\n", Status);
                goto done;
        }

	/* Request the required Nodes for the rpu application */
        Status = XPm_RequestNode(PM_DEV_UART_1, PM_CAP_ACCESS, 0, 0);
		if (XST_SUCCESS != Status) {
			xil_printf("XPm_RequestNode of TTC is failed with error: %d\r\n", Status);
			goto done;
		}

        Status = XPm_RequestNode(PM_DEV_TTC_FOR_TIMER, PM_CAP_ACCESS, 0, 0);
		if (XST_SUCCESS != Status) {
			xil_printf("XPm_RequestNode of TTC is failed with error: %d\r\n", Status);
			goto done;
		}

	Status = XPm_RequestNode(PM_DEV_SWDT_LPD, PM_CAP_ACCESS, 0, 0);
		if (XST_SUCCESS != Status) {
			xil_printf("XPm_RequestNode of TTC is failed with error: %d\r\n", Status);
			goto done;
		}

	if(FullBoot) {
		/* Finalize Initialization */
		Status = XPm_InitFinalize();
		if (XST_SUCCESS != Status) {
			XPm_Dbg("XPm_initfinalize() failed\r\n");
			goto done;
		}
	}
	else {
		xil_printf("BAD Boot: Skipping XPm_InitFinalize\r\n");
	}

done:

	XPm_Dbg("%s Ended", __func__);
        return Status;
}
