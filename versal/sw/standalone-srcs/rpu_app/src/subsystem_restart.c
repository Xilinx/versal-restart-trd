/******************************************************************************
*
* Copyright (C) 2019 - 2021 Xilinx, Inc.  All rights reserved.
* Copyright (c) 2022 - 2025 Advanced Micro Devices, Inc.  All rights reserved.
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
#include "xpm_defs.h"
#include "gic_setup.h"
#include "ipi.h"
#include "pm_init.h"
#include <stdio.h>
#include "xuartpsv.h"
#include "watchdog.h"
#include "rpu_shmem.h"
#include "xil_cache.h"
#include "imagestore.h"

#define TARGET_SUBSYSTEM	PM_SUBSYS_APU

#define ARRAY_SIZE(x)   (sizeof(x) / sizeof((x)[0]))

#define WATCHDOG_ID		XPAR_WDTTB_0_DEVICE_ID
#define WATCHDOG_TIMEOUT_SEC	10

/* RPU Private Persistant Area */
#define RPU_PPA_BASE				0x3E500000
#define RPU_PPA_BAD_BOOT_OFFSET		0x10
#define RPU_BAD_BOOT_KEY			0x37232323
#define RPU_CLEAN_BOOT_KEY			0x0

#ifdef XPAR_XUARTPSV_1_DEVICE_ID
#define UARTPSV_DEVICE_ID		XPAR_XUARTPSV_1_DEVICE_ID
#else
#define UARTPSV_DEVICE_ID		XPAR_XUARTPSV_0_DEVICE_ID
#endif

#define PROGRESS_BAR_MAX		36

#define RESTART_TYPE_SYSTEM		PM_SHUTDOWN_SUBTYPE_RST_SYSTEM
#define RESTART_TYPE_SUBSYSTEM		PM_SHUTDOWN_SUBTYPE_RST_SUBSYSTEM

/*
 * Communication Messages with APU
 */

#define SSR	"Subsystem Restart"
#define SYSR	"System Restart"
#define WDT	"Kill Watchdog"
#define HLTHY	"Do Healthy Boot Test"
#define IMG	"Image Store Test"
#define ALIVE	"Alive"
/*
 * Alternatively use Alive with key
 */
static char alive[] = "Alive0";

static XIpiPsu IpiInst;
static XUartPsv Uart_Psv;
static u32 KeepWdtRunning;

static u32 Uart_init(void)
{
	int Status = XST_SUCCESS;

#ifdef XPAR_XUARTPSV_1_DEVICE_ID
	XUartPsv_Config *Config;

	/*
	 * Initialize the UART driver so that it's ready to use
	 * Look up the configuration in the config table and then
	 * initialize it.
	 */
	Config = XUartPsv_LookupConfig(UARTPSV_DEVICE_ID);
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XUartPsv_CfgInitialize(&Uart_Psv, Config,
					Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
#endif

	return Status;
}

/*
 *  GetBootState :
 *  Returns 1: Good boot
 *  	    0: Bad boot
 *  	    2: Corrupted boot -- for debug purpose
 */
u32 GetBootState()
{
	u32 State = 2; /* corrupted boot */
	u32 boot_status = Xil_In32(RPU_PPA_BASE + RPU_PPA_BAD_BOOT_OFFSET);
	if (boot_status == RPU_BAD_BOOT_KEY) {
		/* bad boot */
		State = 0;
	} else if (boot_status == RPU_CLEAN_BOOT_KEY) {
		/* Good boot */
		State = 1;
	} else {
		/* Corrupted boot state */
		State = 2;
		xil_printf("Received corrupted boot state=0x%X. Ignore for first boot\r\n", boot_status);
	}

	return State;
}

void SetNextBootState(u32 state)
{
	Xil_Out32(RPU_PPA_BASE + RPU_PPA_BAD_BOOT_OFFSET, state);
	Xil_DCacheFlush();
}

static u32 Platform_init(void)
{
	int Status = XST_SUCCESS;

	/*
	 * Do uart initialization for uart 1 if present
	 * UART_1 is pre-alloc so will will be available even
	 * before requesting
	 */
	Status = Uart_init();
	if (XST_SUCCESS != Status) {
		xil_printf("Uart initialization failed ERROR=%d\r\n", Status);
		//TODO: Return/Exit from here
	}

	Status = PmInit(NULL, &IpiInst, GetBootState());
	if (XST_SUCCESS != Status) {
		xil_printf("PM initialization failed ERROR=%d\r\n", Status);
	}
	/* Set Next boot state as clen */
	SetNextBootState(RPU_CLEAN_BOOT_KEY);

	Status = WatchdogInit(WATCHDOG_ID, WATCHDOG_TIMEOUT_SEC);
	if (XST_SUCCESS != Status) {
		xil_printf("Watchdog initialization failed ERROR=%d\r\n", Status);
		KeepWdtRunning = 0;
	}
	else {
		KeepWdtRunning = 1;
	}
	return Status;
}

/**
 * KickWDT() - Kick the watchdog if running
 */
void KickWDT(void) {
	if (KeepWdtRunning == 1) {
		WatchdogKeepAlive();
	}
}

static u32 DoRestart(const u32 RestartType)
{
	int Status = XST_FAILURE;

	/* The subsystem will no more be active. Close the communication */
	rpu_cleanup();
	rpu_finish();
	/* Allow memory sync before the restart -- No neccessary, just for santiy */
	usleep(50 * 1000);

	Status = XPm_SystemShutdown(PM_SHUTDOWN_TYPE_RESET, RestartType);

	if (XST_SUCCESS != Status) {
		xil_printf("API=XPm_SystemShutdown() ERROR=%d\r\n", Status);
		goto done;
	}

	/*
	 * since we attempted to restart, hang here.
	 */
	while(1);

done:
	/*
	 * Since the restart wasn't successful, continue running;
	 * Reconfigure the communication channel
	 */
	rpu_shmem_setup();
	return Status;
}

/**
 * Functions to perform various actions
 */

static u32 DoSubsystemRestart(void)
{
	return DoRestart(RESTART_TYPE_SUBSYSTEM);
}

static u32 DoSystemRestart(void)
{
	return DoRestart(RESTART_TYPE_SYSTEM);
}

static u32 DoKillWatchdog(void)
{
	KeepWdtRunning = 0;
	return 0;
}

static u32 DoHealthyBootTest(void)
{
	/* set the bad boot state and reboot*/
	SetNextBootState(RPU_BAD_BOOT_KEY);
	return DoSubsystemRestart();
}

static u32 DoImageStoreTest(void)
{
	u32 Status = XST_SUCCESS;

	/* Allow memory to clean before Force Powerdown */
	sleep(1);

	Status = XPm_ForcePowerDown(TARGET_SUBSYSTEM, REQUEST_ACK_BLOCKING);
	if (XST_SUCCESS != Status) {
		xil_printf("API=XPm_ForcePowerDown  ERROR=%d\r\n", Status);
		goto done;
	}

	Status = ImageStoreTest(&IpiInst);
	if (XST_SUCCESS != Status) {
		xil_printf("API=ImageStoreTest  ERROR=%d\r\n", Status);
		goto done;
	}

done:
	return Status;
}

typedef u32 (*cmd_func) (void);
typedef struct CommandAction {
	char *cmd;
	cmd_func action;
}CommandAction;

CommandAction CmdList[] ={
	{SSR, DoSubsystemRestart},
	{SYSR, DoSystemRestart},
	{WDT, DoKillWatchdog},
	{HLTHY, DoHealthyBootTest},
	{IMG, DoImageStoreTest},
};

static u32 DoCmdAction()
{
	u32 Status = 0;
	u32 i=0;
	for(i = 0; i < ARRAY_SIZE(CmdList); i++) {
		rpu_load_message(strlen(CmdList[i].cmd));
		if (strcmp(rpu_read_message(), CmdList[i].cmd) == 0) {
			rpu_clear_message();
			Status = CmdList[i].action();
			break;
		}
	}
	return Status;
}

static int ActivityPos(u32 iteration, int max_size)
{
	static int dir = 0;
	int pos = iteration % max_size;

	if(dir)
		pos = max_size - 1 - pos;

	if( iteration % max_size == max_size -1)
		dir = 1 - dir;

	return pos;
}

/**
 * main()- restart the subsystem.
 */
int main()
{
	int Status;
	int i;
	u32 AliveCount = 0;
	int infinite_loop = 1;

	char prog_bar[PROGRESS_BAR_MAX];
	int prog_bar_len = PROGRESS_BAR_MAX - 1;
	int pos = 0;

	Status = Platform_init();
	if (XST_SUCCESS != Status ) {
		xil_printf("Platform init failed ERROR=%d \r\n", Status);
		goto done;
	}

	xil_printf("\tRPU Application started\r\n");
	xil_printf("\tWait 3 seconds for the initialization [For demo purpose]\r\n\n\n");

	sleep(3);

	for(i = 0; i< prog_bar_len; i++)
	{
		prog_bar[i] = ' ';
	}
	prog_bar[prog_bar_len] = '\0';

	rpu_shmem_setup();

	Status = WatchdogEmConfig(&IpiInst);
	if (XST_SUCCESS != Status) {
		xil_printf("\tAPI=EmSetAction  ERROR=%d\r\n", Status);
		goto done;
	}

	while (infinite_loop)
	{
		/* Heartbeats */
		alive[5] += 1;
		if (!alive[5]){
			alive[5] += 1;
		}
		rpu_send_message(alive);

		KickWDT();

		/* Activity Bar */
		pos = ActivityPos(AliveCount, prog_bar_len-2);
		prog_bar[pos] = '<'; prog_bar[pos+1] = '='; prog_bar[pos+2] = '>';
		xil_printf("\tRPU Activity [%s]: %10lu\r", prog_bar, AliveCount/20);
		fflush(stdout);

		AliveCount++;
		prog_bar[pos] = prog_bar[pos+1] = prog_bar[pos+2] = ' ';

		/* Check APU command */
		DoCmdAction();

		usleep(50 * 1000);
	}
done:
	xil_printf("%s End with Status = %d\r\n", __func__, Status);

	return Status;
}

