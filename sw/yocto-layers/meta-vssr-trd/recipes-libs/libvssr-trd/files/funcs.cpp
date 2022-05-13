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

#include <stdlib.h>
#include <stdio.h>

#include "funcs.hpp"
#include "vssr-design.hpp"

#include <pthread.h>
#include <unistd.h>
#include <apu-shmem/apu-shmem.h>

/*
 * Linux commands list
 */
#define LINUX_MARK_SYSTEM_RESTART	"echo system > /sys/devices/platform/firmware:versal-firmware/shutdown_scope"
#define LINUX_MARK_SUBSYSTEM_RESTART	"echo subsystem > /sys/devices/platform/firmware:versal-firmware/shutdown_scope"
#define LINUX_REBOOT_CMD		"reboot"
#define LINUX_WDT_START			"/etc/init.d/watchdog-daemon-init start"
#define LINUX_WDT_KILL			"/etc/init.d/watchdog-daemon-init stop"

/*
 * RPU commands lits
 */
#define RPU_CMD_SS_RESTART		"Subsystem Restart"
#define RPU_CMD_SYS_RESTART		"System Restart"
#define RPU_CMD_WDT_KILL		"Kill Watchdog"
#define RPU_CMD_TEST_HB			"Do Healthy Boot Test"

int init(){
	return apu_setup();
}

int deinit(){
	return apu_finish();
}

char const* getDesignName() {
	return vssr_design_name();
}

static void do_restart(void)
{
	vssr_design_idle();
	system(LINUX_REBOOT_CMD);
}

//char const* SetControl(Agent agent, Target t, Action a)
char const* SetControl(int a_agent, int a_a)
{
	Agent agent =(Agent) a_agent;
	Action a = (Action) a_a;
	if (agent >= E_AgentMax)
		return "Invalid Agent";

	if (a >= E_ActionMax)
		return "Invalid Action";

	if (agent == E_AgentAPU && a == E_ActionSystemRestart )
	{
		system(LINUX_MARK_SYSTEM_RESTART);
		do_restart();
		return "Restarting Full System";
	}

	if (agent == E_AgentAPU && a == E_ActionSubsystemRestart )
	{
		system(LINUX_MARK_SUBSYSTEM_RESTART);
		do_restart();
		return "Restarting APU SubSystem";
	}
	if (agent == E_AgentAPU && a == E_ActionKillWatchdog){
		system(LINUX_WDT_KILL);
		return "Killing APU Watchdog";
	}
	if (agent == E_AgentAPU && a == E_ActionTestHealthyBoot){
		/*Issuing a Subsystem Restart for the user to enter u-boot. RPU will be alive in its
		 *terminal. After stopping in u-boot for 120 ther will be system recovery.
		 *APU and RPU dead in its terminals, then both terminals are getting reloaded with
		 *respective subsystems
		 */
		system(LINUX_MARK_SUBSYSTEM_RESTART);
		do_restart();
		return "to test the healthy boot, press ok and stop at the u-boot hitting any key and wait for 120 seconds and observe system restart ";
	}

	if (agent == E_AgentRPU0 && a == E_ActionSubsystemRestart )
	{
		request_rpu_command(RPU_CMD_SS_RESTART);
		return "Restarting RPU SubSystem";
	}

	if (agent == E_AgentRPU0 && a == E_ActionSystemRestart){
		request_rpu_command(RPU_CMD_SYS_RESTART);
		return "Starting RPU System Restart";
	}

	if (agent == E_AgentRPU0 && a == E_ActionKillWatchdog){
		request_rpu_command(RPU_CMD_WDT_KILL);
		return "Killing RPU Watchdog";
	}
	if (agent == E_AgentRPU0 && a == E_ActionTestHealthyBoot){
		request_rpu_command(RPU_CMD_TEST_HB);
		return "Starting RPU Healthy Boot Test";
	}
	return "This action is not yet supported";
}

int getSubSystemStatus(int a_t)
{
	if(a_t == E_AgentAPU)
	{
		/*
		 * We are here because APU is running
		 */
		return 1;
	}

	if (a_t == E_AgentRPU0)
	{
		return rpu_is_alive();
	}

	return -1;
}
