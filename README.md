# Subsystem Restart TRD

> **[ IMPORTANT ]** <br>
> Versal VCK190 and Versal VMK180 boards are not supported for 2025.2 release with the new EDF Yocto flow. <br>
> Both VCK190 and VMK180 still work on the older Petalinux flow and are available under `versal/` directory. <br>
> Users can also checkout the older tag/commit at **amd/xilinx-v2024.1.1** to build VCK190 and VMK180. <br>

## Table of Contents:
[![Introduction](https://img.shields.io/badge/-1._Introduction-teal)](#introduction)<br>
[![Subsystem Restart TRD](https://img.shields.io/badge/-2_Subsystem_Restart_TRD-purple)](#subsystem-restart-trd)<br>
[![Build Instructions and Artifacts](https://img.shields.io/badge/-3._Build_Instructions_and_Artifacts-darkblue)](#build-instructions-and-artifacts)<br>
[![Changelog](https://img.shields.io/badge/-4._Changelog-grey)](#changelog)<br>

## Introduction
A TRD, i.e Technical Reference Design, is a very insightful way to demonstrate what features and capabilities PLM Firmware has to offer. Each TRD developed aims to target specific set of features for our customers and their usability.<br>
Here are some key changes for 2025.2 and onward releases by PM Team:
- All our TRDs will now be based on the new EDF Yocto Flow.
- When it comes to pre-built images, users/customers can just download the published .wic image and build PDI using EDF flow as described later in the documents.
- The standard boot flow is OSPI + SD Card

<br>

## Subsystem Restart TRD
The Subsystem Restart TRD demonstrates the capability of PLM Firmware to restart a specific subsystem (e.g., Application Processing Unit, Real-Time Processing Unit, etc.) without affecting the operation of other subsystems. This feature is crucial for maintaining system stability and uptime, especially in scenarios where a subsystem may encounter an error or require a reset.

<br>

# Build Instructions and Artifacts
### Software Scripts
```
.
├── supported-boards.yaml
├── edf-yocto-build
│   ├── trd-build.sh                                          # TRD build and install script
│   ├── bitbake-setup.sh                                      # helper script to setup EDF Yocto environment
│   └── bitbake-build.sh                                      # helper script to build TRD within EDF Yocto environment
│
├── subsystem-restart-trd
│   ├── apu_app
│   │   ├── subsys-restart-app.py                             # Runs on APU (linux) in the background
│   │   ├── subsys-restart-cmd.py                             # User friendly command-line interface for subsystem restart (APU or System Controller)
│   │   ├── subsys-restart-funcs.py                           # Contains all subsystem restart level TRD processing
│   │   └── utility.py
│   └── rpmbuild
│       ├── BUILD
│       │   ├── auto-login_service.sh                         # starts linux service on APU to auto-login to root user
│       │   ├── auto-start-subsys-restart_service.sh          # starts linux service on APU to auto-start subsystem restart app
│       │   └── package-install-verify.sh
│       ├── build-package.sh                                  # Build script to package rpm project
│       └── SPECS
│           └── subsys-restart-app.spec                       # RPM spec file to build the package
│
└── versal_2ve_2vm                                            # versal_2ve_2vm platform specific artifacts
.   └── vek385                                                # vek385 board specific artifacts
.  .
.  .
.  .

```

### Common Artifacts
- EDF .wic image: https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html
- EDF SGTGen Directory: https://edf.amd.com/sswreleases/rel-v2025.2/sdt/2025.2/2025.2_1111_1_11112340/external/versal-2ve-2vm-vek385-revb-sdt-seg/

### Installation Steps
- source vitis / vivado `settings64.sh` script

- `trd-build` script `--help`
```bash
./trd-build.sh --help
Usage: ./trd-build.sh [OPTIONS]

Build/Install script for Subsystem Restart TRD using EDF Yocto Setup

Required (choose one):
  -sdt <DIR>          Specify sdtgen output directory
  -xsa <XSA>          Specify hardware design file

Optional:
  -brd <BRD>          Specify board name (default: vek385)
  -cdo <CDO>          Specify overlay CDO file
  -dir <DIR>          Specify output directory (default: versal-2ve-2vm-vek385_2025.2)
  --no-bootbin        Skip EDF bootbin generation (default: false)
  --debug             Enable debug output (default: false)
  --list-boards       List all supported boards
  --help              Display this help message and exit

Examples:
  ./trd-build.sh -sdt /path/to/sdtgen-output
  ./trd-build.sh -xsa design.xsa
  ./trd-build.sh -sdt /path/to/sdtgen-output -cdo custom.cdo --no-bootbin
  ./trd-build.sh -sdt /path/to/sdtgen-output -brd vek385 -dir /path/to/output
```

- run provided trd build script
```bash
cd edf-yocto-build
./trd-build.sh -sdt <provide-sdt-gen-directory-path> -brd <provide-board-name>
```
OR
```bash
cd edf-yocto-build
./trd-build.sh -xsa <provide-xsa-file-path>  -brd <provide-board-name>
```

- Build rpm package
```bash
cd subsystem-restart-trd/rpmbuild
./build-package.sh --board <provide-board-name>
```

- Install the rpm package on both Versal device and System Controller
```bash
rpm -ivh subsys-restart-app-2025.2-1.noarch.rpm
```

- Launch command-line interface either on Versal device or System Controller (we recommend System Controller for better experience)
```bash
python3 /opt/subsys-restart-app/subsys-restart-cmd.py
```

### Generated Artifacts
```bash
edf-yocto-build-artifacts/
├── arm-trusted-firmware.elf
├── base-design.pdi
├── base-pdi-unique-id-vek385-subsystem-restart-trd.txt
├── BOOT_bh.bin
├── BOOT.bin
├── bootbin-version-header-vek385-subsystem-restart-trd.bin
├── bootbin-version-string-vek385-subsystem-restart-trd.txt
├── bootgen.bif
├── cortexa78-linux.dtb
├── hello-world-vek385-subsystem-restart-trd-vek385-subsystem-restart-trd-cortexr52-1-baremetal.elf
├── plmfw.elf
├── qemu-ospi.bin
├── tee-raw.bin
└── u-boot.elf
```

<br>

> For Detailed Changelog/Revisions, please refer: [CHANGELOG.md](./CHANGELOG.md)