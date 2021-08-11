# Versal Restart TRD
[![Docs](https://img.shields.io/badge/-Documention-blue)](https://xilinx.github.io/versal-restart-trd)
[![prebuilt](https://img.shields.io/badge/-Prebuilt_Images-blueviolet)](#prebuilt-images)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![Tools](https://img.shields.io/badge/Xilinx_Tools_Version-2021.1-orange)](https://www.xilinx.com/)

The Versal System and Subsystem Restart TRD (**VSSR TRD**), also referred to as
**Versal Restart TRD**, demonstrates how to restart various components of a system.
It also showcases the liveliness of a subsystem while another subsystem is undergoing
restart.

The TRD consists of a baseline Vivado design, Petalinux, Jupyter notebooks and other
software components to demonstrate different restart scenarios.

This repository provides all the sources of TRD and their build infrastructure.

## Links

### [Documentation](https://xilinx.github.io/versal-restart-trd)

### Prebuilt Images
#### Prebuilt Images for Production Silicon
Board   | Silicon        | Download Link
--------|----------------|--------------
VCK190  | Production     | [vssr-trd-pb-vck190-prod-2021.1.zip](https://www.xilinx.com/bin/public/openDownload?filename=vssr-trd-pb-vck190-prod-2021.1.zip)
VMK180  | Production     | [vssr-trd-pb-vmk180-prod-2021.1.zip](https://www.xilinx.com/bin/public/openDownload?filename=vssr-trd-pb-vmk180-prod-2021.1.zip)

#### Prebuilt Images for ES Silicon
Board   | Silicon            | Download Link
--------|--------------------|--------------
VCK190  | Engineering Sample | [vssr-trd-pb-vck190-es1-2021.1.zip](https://www.xilinx.com/member/vck190_headstart/vssr-trd-pb-vck190-es1-2021.1.zip)
VMk180  | Engineering Sample | [vssr-trd-pb-vmk180-es1-2021.1.zip](https://www.xilinx.com/member/vmk180_headstart/vssr-trd-pb-vmk180-es1-2021.1.zip)

> Engineering Samples or ES (including es1) refers to early access silicon which can only be given out to customers with a valid NDA.  Access to ES Documentation and Designs is only available on the VCK190 and VMK180 HeadStart Lounge web pages.  These pages require a special login for those customers with a valid NDA.

#### Licenses for Prebuilt Images : [vssr-trd-pb-license-2021.1.tar.gz](https://www.xilinx.com/bin/public/openDownload?filename=vssr-trd-pb-licenses-2021.1.tar.gz)

### Xilinx Tools
Tools       | Download Link
------------|--------------
Vivado      | [2021.1](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2021-1.html)
Vitis       | [2021.1](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vitis/2021-1.html)
Petalinux   | [2021.1](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools/2021-1.html)


## Directory Structure

### Top Level Files
```
├── hw              # Sources to build hardware design
├── sw              # Sources to build software components and SD image
├── docs            # Sources to build documentation
├── Makefile        # Top level makefile to build docs, sw, and hw
├── LICENSE         # Project License information
└── README.md       # This Readme file
```

### Hardware Sources
```
hw
├── common             # Common files used across all designs
├── ip_repo            # Common files used across all designs
├── Makefile           # Makefile to build hardware designs
├── vck190_es1_base    # Source files for specific board variant and design
├── vck190_prod_base   # Source files for specific board variant and design
├── vmk180_es1_base    # Source files for specific board variant and design
└── vmk180_prod_base   # Source files for specific board variant and design
```

### Software Sources
```
sw
├── Makefile            # Makefile to build software components
├── scripts
│   ├── plnx-cfg        # Script to configure petalinux project
│   └── rpu_build.tcl   # Script to build rpu application through xsct
├── standalone-srcs
│   └── rpu_app         # Rpu application sources
└── yocto-layers
    └── meta-vssr-trd   # Yocto layer for the TRD
```

## Build Instruction
The hardware design and the software components can be build using the Makefile(s)
in the repository. The top level Makefile invokes sub makefiles inside docs, hw
and sw to build documentation, hardware and software respectively.

### Setting Environment

Following environment setup is required for various component builds:

Component | Environment
----------|------------
Hardware  | Vivado: To build hardware design
Software  | Petalinux: To build petalinux project and sd card images<br> Vitis/Vivado: To invoke xsct for RPU application build
Documentations | Sphinx

- Vivado: Source the `settings64.sh` script from the Vivado installation path.
- Petalinux: Source the `settings64.sh` script from the Petalinux installation path.
- Sphinx: Install [Sphinx](https://www.sphinx-doc.org/en/master/usage/installation.html) & [recommonmark](https://recommonmark.readthedocs.io/en/latest/)

### Makefiles

The top level makefile can be invoked using `make` command with following format:

```
make [<target>] [<Option1>=<val1> [<Option2>=<val2>]...]
```

Each make invocation is with respect to specific build configuration. The build configuration is defined as combination of
- Board (vck190, vmk180)
- Silicon (production, es1)
- Design (base)

Currently there is only one design, but in future there can be more designs. Build configuration is selected using various make options.

To build the default image for vck190 board with production silicon, just run

```
make
```

To build just hardware images for the vmk180 production silicon, run

```
make build_hw BOARD=vmk180 SIL=prod
```

To see various possible targets, options and examples run

```
make help
```


Below are various **targets and options**:

Targets | Description
--------|------------
build_sw<br>build_sdcard | Default target. Builds everything required to generate the sd card image for the chosen build configuration.
build_hw                 | Builds hardware images
build_docs               | Generate html documentation
clean                    | Clean the build area for sw and hw for the given build-config
nuke                     | Remove build and deploy(output) area completely for given config

Options       | Possible Values | Default | Description          | Applies to Target
--------------|----------------|---------|----------------------|----------------------
BOARD=\<val\>   | vck190, vmk180 | vck190  | Choose board variant | All, except build_docs
SIL=\<val\>     | prod, es1      | prod    | Choose silicon variant | All, except build_docs
DESIGN=\<val\>  | base           | base    | Choose Design variant(for future) | All, except build_docs
BUILD_DIR=\<path\> | Valid Absolute path | ./build | Choose custom build scratchpad area(Min 50GB) | All
XSA_FILE=\<file\> | XSA file | generated xsa | Custom XSA file for sw build | build_sw<br>build_sdcard

> XSA_FILE: During build_hw, the xsa file generated and deployed at `./output/<build-config>/reference_images/versal_restart_trd_wrapper.xsa`. This is referred as generated xsa in above table. During the software build, If default xsa file does not exist and no XSA_FILE is provided, build_hw target is automatically invoked to build the hardware.

> Note: Experienced users can read, understand use the sub-make files in the sub directories directly. But it recommended to use the top level Makefile to track the dependencies.

### Build and Deploy Area

All the sources are built under build directory (default to ./build, unless changed by `BUILD_DIR` option).

Following are the build areas for various components:
- Hardware: `${BUILD_DIR}/${BOARD}-${SIL}-${DESIGN}/hw`
- Software: `${BUILD_DIR}/${BOARD}-${SIL}-${DESIGN}/sw`
- Documentation: `${BUILD_DIR}/docs`

After the build is completed, the artifacts are copied to deploy area:
- Hardware: `./output/${BOARD}-${SIL}-${DESIGN}/hw`
- Software: `.output/${BOARD}-${SIL}-${DESIGN}/sw`
- Documentation: `.output/docs`

Final deploy output will look as follow:
```
  output/
  ├── docs
  │   ├── ...doc-files
  │   └── index.html
  ├── vck190-es1-base
  │   ├── petalinux-sdimage.wic.xz
  │   └── reference_images
  ├── vck190-prod-base
  │   ├── petalinux-sdimage.wic.xz
  │   └── reference_images
  ├── vmk180-es1-base
  │   ├── petalinux-sdimage.wic.xz
  │   └── reference_images
  └── vmk180-prod-base
      ├── petalinux-sdimage.wic.xz
      └── reference_images
```

**petalinux-sdimage.wic.xz** file is used for flashing the sd card and running on target as described in the [documentation](#links). The files under reference_images are all included in the wic image and not required to be consumed separately. Following reference artifacts are copied after the build.

```
      └── reference_images
          ├── bl31.elf
          ├── boot.bif
          ├── BOOT.BIN
          ├── boot.scr
          ├── Image
          ├── plm.elf
          ├── psmfw.elf
          ├── ramdisk.cpio.gz.u-boot
          ├── rootfs.tar.gz
          ├── rpu_app.elf
          ├── system.dtb
          ├── u-boot.elf
          ├── versal_restart_trd_wrapper.pdi
          └── versal_restart_trd_wrapper.xsa
```

Refer [documentation](#links) for detail build instructions for hardware and software.

## Run Instructions

Refer **Run Images on Target** section in the [documentation](#links).

## License

```
Copyright (C) 2019 - 2021 Xilinx, Inc.  All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
