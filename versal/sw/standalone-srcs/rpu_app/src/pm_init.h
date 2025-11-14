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

/* Subsystem definitions */
#define PM_SUBSYS_APU                           (0x1c000003U)

/* Select TTC for timer based on xparameters.h */
#if (SLEEP_TIMER_BASEADDR == XPAR_VERSAL_CIPS_0_PSPMC_0_PSV_TTC_0_BASEADDR)
        #define PM_DEV_TTC_FOR_TIMER PM_DEV_TTC_0
#elif (SLEEP_TIMER_BASEADDR  == XPAR_VERSAL_CIPS_0_PSPMC_0_PSV_TTC_3_BASEADDR)
        #define PM_DEV_TTC_FOR_TIMER PM_DEV_TTC_1
#elif (SLEEP_TIMER_BASEADDR  == XPAR_VERSAL_CIPS_0_PSPMC_0_PSV_TTC_6_BASEADDR)
        #define PM_DEV_TTC_FOR_TIMER PM_DEV_TTC_2
#elif (SLEEP_TIMER_BASEADDR  == XPAR_VERSAL_CIPS_0_PSPMC_0_PSV_TTC_9_BASEADDR)
        #define PM_DEV_TTC_FOR_TIMER PM_DEV_TTC_3
#endif

#ifndef _PM_INIT_H_
#define _PM_INIT_H_


XStatus PmInit(XScuGic *const GicInst, XIpiPsu *const IpiInst, u32 FullBoot);

#endif
