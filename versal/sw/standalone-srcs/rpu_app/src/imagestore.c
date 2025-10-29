/******************************************************************************
* Copyright (c) 2022 - 2023 Advanced Micro Devices, Inc.  All rights reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/

#include <stdio.h>
#include "xil_printf.h"
#include "xparameters.h"
#include "xipipsu.h"
#include "xil_cache.h"

#if defined(VERSAL_NET)
#define TARGET_IPI_INT_MASK	XPAR_XIPIPS_TARGET_PSX_PMC_0_CH0_MASK
#else
#define TARGET_IPI_INT_MASK	XPAR_XIPIPS_TARGET_PSV_PMC_0_CH0_MASK
#endif

#define IPI_TIMEOUT		(0xFFFFFFFFU)

/* Example defines below, update with required values*/
#define PDI_ID 0xABU  /*ID to identify PDI */
#define PDI_ADDRESS_LOW PDI_ID /* PDI Low Address in Memory */
#define PDI_ADDRESS_HIGH 0x00000000U /* PDI High Address in Memory */
#define XLOADER_PDI_SRC_IS              (0x10U)
#define HEADER(Len, ModuleId, CmdId)	((Len << 16U) | (ModuleId << 8U) | CmdId)
#define LOAD_PDI_CMD_PAYLOAD_LEN	(3U)
#define XILLOADER_MODULE_ID		(7U)
#define XILLOADER_LOAD_PPDI_CMD_ID	(1U)

u32 ImageStoreTest(XIpiPsu *IpiInst)
{
	u32 Status = XST_FAILURE;
	u32 Response;

	u32 Payload[] = {HEADER(LOAD_PDI_CMD_PAYLOAD_LEN, XILLOADER_MODULE_ID,
				XILLOADER_LOAD_PPDI_CMD_ID),
				XLOADER_PDI_SRC_IS, PDI_ADDRESS_HIGH,
				PDI_ADDRESS_LOW};

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

	Status = (int)Response;

END:
	return Status;
}
