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

#include "gic_setup.h"
#include "pm_client.h"
#include <xscugic_hw.h>

#define INTC_DEVICE_ID		XPAR_SCUGIC_SINGLE_DEVICE_ID

typedef struct {
	void *CallBackRef;
	u8 Enabled;
} GicIrqEntry;

static GicIrqEntry GicIrqTable[XSCUGIC_MAX_NUM_INTR_INPUTS];

s32 GicSetupInterruptSystem(XScuGic *GicInst)
{
	s32 Status;

	XScuGic_Config *GicCfgPtr = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == GicCfgPtr) {
		XPm_Dbg("XScuGic_LookupConfig() failed\r\n");
		goto done;
	}

	Status = XScuGic_CfgInitialize(GicInst, GicCfgPtr, GicCfgPtr->CpuBaseAddress);
	if (XST_SUCCESS != Status) {
		XPm_Dbg("XScuGic_CfgInitialize() failed with error: %d\r\n", Status);
		goto done;
	}

	/*
	 * Connect the interrupt controller interrupt Handler to the
	 * hardware interrupt handling logic in the processor.
	 */
#if defined (__aarch64__)
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_FIQ_INT,
#elif defined (__arm__)
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
#endif
				     (Xil_ExceptionHandler)XScuGic_InterruptHandler,
				     GicInst);
	Xil_ExceptionEnable();

done:
	return Status;
}

s32 GicResume(XScuGic *GicInst)
{
	s32 Status;
	u32 i;

	GicInst->IsReady = 0U;

#if defined (GICv3)
	XScuGic_MarkCoreAwake(GicInst);
#endif

	XScuGic_Config *GicCfgPtr = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == GicCfgPtr) {
		XPm_Dbg("XScuGic_LookupConfig() failed\r\n");
		goto done;
	}

	Status = XScuGic_CfgInitialize(GicInst, GicCfgPtr, GicCfgPtr->CpuBaseAddress);
	if (XST_SUCCESS != Status) {
		XPm_Dbg("XScuGic_CfgInitialize() failed with error: %d\r\n", Status);
		goto done;
	}

	/* Restore handler pointers and enable interrupt if it was enabled */
	for (i = 0U; i < XSCUGIC_MAX_NUM_INTR_INPUTS; i++) {
		GicInst->Config->HandlerTable[i].CallBackRef = GicIrqTable[i].CallBackRef;

		if (GicIrqTable[i].Enabled){
			XScuGic_Enable(GicInst, i);
		}
	}

	Xil_ExceptionEnable();

done:
	return Status;

}

void GicSuspend(XScuGic *const GicInst)
{
	u32 i;

	for (i = 0U; i < XSCUGIC_MAX_NUM_INTR_INPUTS; i++) {
		u32 Mask, Reg;

		GicIrqTable[i].CallBackRef = GicInst->Config->HandlerTable[i].CallBackRef;

		Mask = 0x00000001U << (i % 32U);
		Reg = XScuGic_DistReadReg(GicInst, XSCUGIC_ENABLE_SET_OFFSET +
					  ((i / 32U) * 4U));
		if (Mask & Reg)
			GicIrqTable[i].Enabled = 1U;
		else
			GicIrqTable[i].Enabled = 0U;
	}

#if defined (GICv3)
	XScuGic_MarkCoreAsleep(GicInst);
#endif
}
