# T50 - Subsystem Restart / Power States TRD

## Table of Contents:
[![Introduction](https://img.shields.io/badge/-1._Introduction-darkgreen)](#introduction)<br>
[![Subsystem Restart TRD](https://img.shields.io/badge/-2_Subsystem_Restart_TRD-purple)](#subsystem-restart-trd)<br>
[![Power States TRD](https://img.shields.io/badge/-3._Power_States_TRD-darkred)](#power-states-trd)<br>
[![Build Instructions and Artifacts](https://img.shields.io/badge/-4._Build_Instructions_and_Artifacts-blue)](#build-instructions-and-artifacts)<br>
[![What's Upcoming?](https://img.shields.io/badge/-5._What's_Upcoming%3F-grey)](#whats-upcoming)<br>
[![Developer's Guide](https://img.shields.io/badge/-6._Developer's_Guide-white)](#developers-guide)<br>

## Introduction
A TRD, i.e Techincal Reference Design, is a very insightful way to demostrate what features and capabilities PLM Firmware has to offer. Each TRD developed aims to target specific set of features for our customers and their usability.<br>
Here are some key changes for 2025.2 and onward releases by PM Team:
- All our TRDs will now be based on the new EDF Yocto Flow.
- When it comes to pre-built images, users/customers can just download the published .wic image and build PDI using EDF flow as described later in the documents.
- The standard boot flow is OSPI + SD Card

<br>

## Subsystem Restart TRD
The xc2ve3858 device based on Versal AI Gen2 Architecture has 8 A78 Arm Cores and 10 R52 Arm Cores for APU and RPU respectively. Subsystem Restart TRD demonstrates how various components perform restarts with software level isolation using Subsystem Configuration. <br>
- This TRD consists of a Custom Subsystem 6 which isolates all the APU cores running linux.
- User gets a comprehensive command-line interface to interact with; which helps them perform Subsystem and System level restarts.
- This interface can run on both: Linux running on APU as well as our System Controllers.
- We recommend running the interface on System Controller to get the full experience of what this TRD aims at. 

### Running Command-Line Interface
```console
root@amd-edf:~# python /opt/subsys-restart-app/subsys-restart-cmd.py 
[INFO] Package running on System Controller


/----┬-----------------------┬---------------------------------------------------------------------------------------------\
| ID |         Name          |                                         Description                                         |
|----|-----------------------|---------------------------------------------------------------------------------------------|
| 1  | APU Subsystem Restart | APU performs a self-subsystem restart. APU talks to PLM to perform subsystem shutdown scope |
| 2  |  APU System Restart   |      APU performs a system restart. APU talks to PLM to perform system shutdown scope       |
| 0  |         Exit          |                                     Close TSSR TRD App!                                     |
\----┻-----------------------┻---------------------------------------------------------------------------------------------/
Select an operation ID: 
```

<br>

## Power States TRD
The xc2ve3858 device based on Versal AI Gen2 Architecture has 8 A78 Arm Cores and 10 R52 Arm Cores for APU and RPU respectively. Power States TRD demonstrates how various components on Versal2 device cause changes in different power domains using out-of-box Default Subsystem. <br>
- This TRD consists of Default Subsystem (built within PLM Firmware) running linux on APU.
- User gets a comprehensive command-line interface to interact with; which helps them transition to various pre-built power states showcasing changes across power domains.
- This interface can run on both: Linux running on APU as well as our System Controllers.
- We recommend running the interface on System Controller to get the full experience of what this TRD aims at.
- Note: System Controller image supports RAFT tool part of BEAM utility, which displays a comprehensive view of power across various rails/componenets/domains. But if user wants, they can use the simplified power table that comes with the TRD ( but only works on System Controller ).

### Running Command-Line Interface
```console
root@amd-edf:~# python /opt/power-states-app/power-states-cmd.py 
[INFO] Package running on System Controller


/----┬---------------------┬--------------------------------------------------------\
| ID |        State        |                      Description                       |
|----|---------------------|--------------------------------------------------------|
| 1  | Reference (default) |     APU default to out-of-the-box reference state      |
| 2  |     Full Power      |     APU running linux with both cores active @<>Hz     |
| 3  |      APU0 Only      | APU running linux on core0 only (core[1-7] turned off) |
| 0  |        Exit         |             Closing Power States TRD App!              |
\----┻---------------------┻--------------------------------------------------------/
Select an operation ID: 
```
```console
Select an operation ID: 2


Changing Power State to Full Power
[INFO] Description: APU running linux with both cores active @<>Hz

APU Completed Execution: ACK=0x55, isAlive=0

[INFO] Press any key to stop monitoring power values...

Rail: LPD          | Power:    1.117W
Rail: FPD          | Power:    7.212W
Rail: System       | Power:    7.938W
Rail: PLD          | Power:    1.054W
Rail: AIE          | Power:    1.052W
Rail: Total Power  | Power:   18.373W
```

<br>


## Build Instructions and Artifacts
#### Software Scripts
```
.
├── edf-yocto-build
|   ├── trd-build.sh                    # main script to build entire TRD (subsystem-restart only)
|   ├── bitbake-setup.sh                # setup installation for EDF Yocto locally
|   ├── bitbake-build.sh                # build script for EDF Yocto artifacts
|   └── subsystem-restart
|       └── recipe-bsp
|           └── bootbin
|              ├── versal-2ve-2vm-apu-subsys.inc        # APU Subsystem over-loading configurations in EDF
|              ├── versal-2ve-2vm-rpu-subsys.inc        # RPU Subsystem over-loading configurations in EDF
|              └── xilinx-bootbin_1.0.bbappend          # Recipe to over-load xilinx-bootbin default EDF recipe
├── power-states-trd
|   ├── apu_app
|   |   ├── power-states-app.py                         # Runs on APU (linux) in the background
|   |   ├── power-states-cmd.py                         # User friendly command-line interface for power states (APU or System Controller)
|   |   ├── power-states-funcs.py                       # Contains all power states level TRD processing
|   |   └── utility.py
|   └── rpmbuild
|       ├── build-package.sh
|       ├── BUILD
|       |   └── power-states-app-2025.2
|       |       ├── auto-login_service.sh               # starts linux service on APU to auto-login to root user
|       |       ├── auto-start-power-states_service.sh  # starts linux service on APU to auto-start power states app
|       |       ├── package-install-verify.sh
|       |       ├── power-states-app.py
|       |       ├── power-states-cmd.py
|       |       ├── power-states-funcs.py
|       |       └── utility.py
|       └── RPMS
|           └── noarch
|               └── power-states-app-2025.2-1.noarch.rpm        # install this package on APU and System Controller
|
└── subsystem-restart-trd
|   ├── apu_app
|   |   ├── subsys-restart-app.py                       # Runs on APU (linux) in the background
|   |   ├── subsys-restart-cmd.py                       # User friendly command-line interface for subsystem restart (APU or System Controller)
|   |   ├── subsys-restart-funcs.py                     # Contains all subsystem restart level TRD processing
|   |   └── utility.py
|   ├── isoutil-project
|   |   ├── isospec.cdo
|   |   ├── isospec.iss
|   |   └── subsys-overlay.cdo
|   └── rpmbuild
|       ├── build-package.sh
|       ├── BUILD
|       |   └── subsys-restart-app-2025.2
|       |       ├── auto-login_service.sh                 # starts linux service on APU to auto-login to root user
|       |       ├── auto-start-subsys-restart_service.sh  # starts linux service on APU to auto-start subsystem restart app
|       |       ├── package-install-verify.sh
|       |       ├── subsys-restart-app.py
|       |       ├── subsys-restart-cmd.py
|       |       ├── subsys-restart-funcs.py
|       |       └── utility.py
|       └── RPMS
|           └── noarch
|               └── subsys-restart-app-2025.2-1.noarch.rpm      # install this package on APU and System Controller
```

### Common Artifacts
- EDF .wic image: https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html
- EDF SDTGEN Directory: https://petalinux.xilinx.com/sswreleases/rel-v2025.1/sdt/2025.1/2025.1_0530_1_07282301/external/versal-2ve-2vm-vek385-sdt-seg/

#### Subsystem Restart TRD
- source vitis / vivado `settings64.sh` script
```
Eg: source /proj/primebuilds/2025.2_PRIME_daily_latest/installs/lin64/2025.2/Vitis/settings64.sh
```
- run provided trd build script
```
./trd-build.sh subsystem-restart
```
- Install the rpm package on both Versal2 and System Controller
```
rpm -ivh subsys-restart-app-2025.2-1.noarch.rpm
```
- Launch command-line interface either on Versal2 or System Controller (we recommend System Controller for better experience)
```
python3 /opt/subsys-restart-app/subsys-restart-cmd.py
```
#### Power States TRD
- No EDF customization or build require for Power States TRD (at least for 2025.2 release). Please use the default out-of-box EDF artifacts.
- Install the rpm package on both Versal2 and System Controller
```
rpm -ivh power-states-app-2025.2-1.noarch.rpm
```
- Launch command-line interface either on Versal2 or System Controller (we recommend System Controller for better experience)
```
python3 /opt/power-states-app/power-states-cmd.py
```

## What's Upcoming?
- RPU application for Subsystem Restart and Power States TRD
- Jupyter Notebook support for both Subsystem Restart and Power States TRD
- Controller option on RPU running Zephyr OS
- New power states (like AIE, PL, etc) coming to Power States TRD
- Watchdog Timer and Image Store recovery options coming to Subsystem Restart TRD
- Building .rpm package within EDF framework (or might get completely overhauled with Docker Image approach)


## Developer's Guide
### TRD Software Overview
* Both APU (linux) and RPU (Baremetal) talk to PLM to perform various TRD tasks.
* There is no direct communication between APU and RPU (as of 2025.2 release).
* APU, RPU and System Controller communicate via DDR Memory ( which is accessible to all).
  * APU uses `devmem2` utility tool to read/write to DDR Memory.
  * RPU uses xilpm-ng `Xil_In32()` and `Xil_Out32()` to read/write to DDR Memory.
  * System Controller uses `XSDB` to perform read/write operations on DDR Memory.
* With the help of `DRMsg Protocol`, a custom message sharing over DDR Memory, TRD can perform several tasks!
  * A slave (eg: APU) polls it's specific region in DDR space, waiting to perform necessary action. The application `*-app.py` contents this algorithm.
  * The master, which could either be a PS block or System Controller, provide a command-line interface to the user, which orders slave to execute necessary TRD task.
  * Please refer the following link on DRMsg Protocol: https://amd.atlassian.net/wiki/x/S9tdOg
```
         ╔═════════════════════════════════════╗
         ║                 PLM                 ║
         ╚══╦═══════════════════════════════╦══╝
            ▲                               ▲
            │                               │
            │                               │
            ▼                               ▼
╔═════════════════╗                    ╔═════════════════╗
║                 ║                    ║                 ║
║       APU       ║                    ║       RPU       ║
║                 ║                    ║                 ║
╚═════════════════╝                    ╚═════════════════╝
         ▲                                      ▲
         │                                      │
         └────────┐                    ┌────────┘
                  │                    │
                  ▼                    ▼
         ╔══════════════════════════════════════╗
         ║                                      ║
         ║              DDR Memory              ║
         ║                                      ║
         ╚══════════════════════════════════════╝
                             ▲
                             │
                             │
                             ▼
             ╔═══════════════════════════════╗
             ║                               ║
             ║       System Controller       ║
             ║                               ║
             ╚═══════════════════════════════╝
```

### EDF Yocto Overview
* Customers directly use SDTGEN published here: https://petalinux.xilinx.com/sswreleases/rel-v2025.1/sdt/2025.1/2025.1_0530_1_07282301/external/versal-2ve-2vm-vek385-sdt-seg/ (we can interally use .XSA to generate SDTGEN if needed).
* Overlay CDO will contain all the subsystem customizations and confirations.
* In EDF Yocto Setup, we create our custom meta layer for TRD(s).
* With `gen-machine-conf`, we generate our custom machine by inheriting the default `versal-2ve-2vm-vek385-sdt-seg` machine provided by EDF.
* Following bitbake command over-writes xilinx-bootbin recipe to build necessary artifacts: `MACHINE=<custom-machine-name> bitbake xilinx-bootbin`
```
╔════════════════╗          ╔════════════════╗          ╔════════════════╗          ╔════════════════╗          ╔════════════════╗          ╔════════════════╗
║                ║          ║                ║          ║                ║          ║     TRD        ║          ║      GEN       ║          ║                ║
║      .XSA      ║  ─────►  ║   SDTGEN DIR   ║  ─────►  ║  OVERLAY CDO   ║  ─────►  ║   EDF YOCTO    ║  ─────►  ║     MACHINE    ║  ─────►  ║    BITBAKE     ║
║                ║          ║                ║          ║                ║          ║     SETUP      ║          ║      CONF      ║          ║                ║
╚════════════════╝          ╚════════════════╝          ╚════════════════╝          ╚════════════════╝          ╚════════════════╝          ╚════════════════╝
```

### RPM Package Overview
* `build-package.sh` takes care of building *.rpm package for TRD(s).
* `rpmbuild/BUILD/<>-2025.2/` directory had all the scripts and source files for TRD.
* The generated .rpm package should be available at `rpmbuild/RPMS/` directory.
* The generated .rpm package can be installed on both APU as well as System Controller.
  * The package looks for `sc_app` as an identifier to determine whether the host is Versal2 device or System Controller.
  * With this intelligence, the package configures and installs the necessary components accordingly.
* The `/opt/<>/*-cmd.py` script can run on either System Controller or Versal2 (running on System Controller is good, as it gives complete visual of what's happening)
* To properly uninstall the .rpm package: `rpm -e <package-name>`