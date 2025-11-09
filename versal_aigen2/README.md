# Subsystem Restart TRD for Versal AI Gen2 (vek385)

## Table of Contents:
[![Introduction](https://img.shields.io/badge/-1._Introduction-darkgreen)](#introduction)<br>
[![Subsystem Restart TRD](https://img.shields.io/badge/-2_Subsystem_Restart_TRD-purple)](#subsystem-restart-trd)<br>
[![Build Instructions and Artifacts](https://img.shields.io/badge/-3._Build_Instructions_and_Artifacts-blue)](#build-instructions-and-artifacts)<br>
[![What's Upcoming?](https://img.shields.io/badge/-4._What's_Upcoming%3F-grey)](#whats-upcoming)<br>
[![Developer's Guide](https://img.shields.io/badge/-5._Developer's_Guide-white)](#developers-guide)<br>

## Introduction
A TRD, i.e Techincal Reference Design, is a very insightful way to demostrate what features and capabilities PLM Firmware has to offer. Each TRD developed aims to target specific set of features for our customers and their usability.<br>
Here are some key changes for 2025.2 and onward releases by PM Team:
- All our TRDs will now be based on the new EDF Yocto Flow.
- When it comes to pre-built images, users/customers can just download the published .wic image and build PDI using EDF flow as described later in the documents.
- The standard boot flow is OSPI + SD Card

<br>

## Subsystem Restart TRD
The vek385 device based on Versal AI Gen2 Architecture has 8 A78 Arm Cores and 10 R52 Arm Cores for APU and RPU respectively. Subsystem Restart TRD demonstrates how various components perform restarts with software level isolation using Subsystem Configuration. <br>
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


## Build Instructions and Artifacts
#### Software Scripts
```
.
├── edf-yocto-build
|   ├── trd-build.sh                                    # TRD build and install script
|   ├── bitbake-setup.sh                                # helper script to setup EDF Yocto environment
|   ├── bitbake-build.sh                                # helper script to build TRD within EDF Yocto environment
|   └── recipes-bsp                                     # TRD specific recipes to be added to EDF Yocto build
|       └── bootbin
|           ├── versal-2ve-2vm-apu-subsys.inc
|           ├── versal-2ve-2vm-rpu-subsys.inc
|           └── xilinx-bootbin_1.0.bbappend
├── subsystem-restart-trd
|   ├── apu_app
|   |   ├── subsys-restart-app.py                               # Runs on APU (linux) in the background
|   |   ├── subsys-restart-cmd.py                               # User friendly command-line interface for subsystem restart (APU or System Controller)
|   |   ├── subsys-restart-funcs.py                             # Contains all subsystem restart level TRD processing
|   |   └── utility.py
|   ├── isoutil-project
|   |   ├── isospec.iss
|   |   └── subsys-overlay.cdo
|   └── rpmbuild
|       ├── build-package.sh
|       ├── BUILD
|       |   └── subsys-restart-app-2025.2
|       |       ├── auto-login_service.sh                       # starts linux service on APU to auto-login to root user
|       |       ├── auto-start-subsys-restart_service.sh        # starts linux service on APU to auto-start subsystem restart app
|       |       ├── package-install-verify.sh
|       |       ├── subsys-restart-app.py
|       |       ├── subsys-restart-cmd.py
|       |       ├── subsys-restart-funcs.py
|       |       └── utility.py
|       ├── SPECS
|       |   └── subsys-restart-app.spec                         # RPM spec file to build the package
|       └── RPMS
|           └── noarch
|               └── subsys-restart-app-2025.2-1.noarch.rpm      # install this package on APU and System Controller (built using build-package.sh)
└── vek385                                                      # vek385 device specific files
    └── config.json                                             # vek385 device configuration for the TRD application(s)

```

### Common Artifacts
- EDF .wic image: https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html
- EDF SDTGEN Directory: https://petalinux.xilinx.com/sswreleases/rel-v2025.1/sdt/2025.1/2025.1_0530_1_07282301/external/versal-2ve-2vm-vek385-sdt-seg/

#### Installation Steps
- source vitis / vivado `settings64.sh` script
- run provided trd build script
```bash
./trd-build.sh -sdt <provide-sdt-gen-directory-path>
```
OR
```bash
./trd-build.sh -xsa <provide-xsa-file-path>
```
- Build rpm package
```bash
./build-package.sh
```
OR
```bash
./build-package.sh -cache
```
- Install the rpm package on both Versal2 and System Controller
```bash
rpm -ivh subsys-restart-app-2025.2-1.noarch.rpm
```
- Launch command-line interface either on Versal2 or System Controller (we recommend System Controller for better experience)
```bash
python3 /opt/subsys-restart-app/subsys-restart-cmd.py
```

## What's Upcoming?
- RPU Baremetal application for Subsystem Restart
- Jupyter Notebook support for both Subsystem Restart
- Controller option on RPU running Zephyr OS
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