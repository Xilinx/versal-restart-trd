/******************************************************************************
*
* Copyright (C) 2019 - 2021 Xilinx, Inc.  All rights reserved.
* Copyright (c) 2022 - 2023 Advanced Micro Devices, Inc.  All rights reserved.
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

#ifndef _FUNCS_HPP_
#define _FUNCS_HPP_

enum Action {
	E_ActionSubsystemRestart,
	E_ActionSystemRestart,
	E_ActionTestHealthyBoot,
	E_ActionStartWatchdog,
	E_ActionKillWatchdog,
	E_ActionTestImageStore,
	E_ActionMax
};

enum Agent {
	E_AgentAPU,
	E_AgentRPU0,
	E_AgentRPU1,
	E_AgentMax
};

int init(void);
int deinit(void);
char const* getDesignName (void);
int getSubSystemStatus(int a_t);
char const* SetControl(int a_agent, int a_a);


#endif /* _FUNCS_HPP_ */
