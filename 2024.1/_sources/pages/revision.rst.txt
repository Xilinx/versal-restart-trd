Revision History
================
**2024.1**

* Updates in sw component

  * Fix an image store issue and a watchdog issue both in rpu_app

  * Update makefile compatible with 2024.1 release

**2023.2**

* Updates in hw component

  * Upadtes subsystem cdo as per image store feature

* Updates in sw component

  * Add Image store feature test case

**2023.1**

* Updates in hw components

  * Change subsystem marker as per Vivado 2023.1 design

* Updates in sw components

  * Change recipes as per updated packages in 2023.1 release

**2022.2**

* Updates in sw components

  * Update linker script due to memory overflow issue in rpu_app

* Updates in hw components

  * Update subsystem CDO to make the TRD compatible with 2022.2 release

**2022.1**

* Updated for 2022.1 toolchain

  * Removed support for ES1 silicon

  * Migrate to systemd as init system

  * Subsystem definition's cdo file made more verbose

  * Unify the subsystem cdo definition for all boards

    * Removed AIE requirement from all the cores by default (can be added back by uncommenting)

**2021.2 v2.1.0**

* Updated for 2021.2

  * Added APU and RPU Subsystem Recovery with WDT

**2021.1 v2.0.0**

* Updated for 2021.1

  * Changed Release format: Source on Github and Binaries on Xilinx.com through zip file

  * New features: Healthy Boot, Recovery with WDT, CDO Overlay

  * Improved Jupyter dashboard layout

  * RPU now demonstrate all the features like APU

  * Removed unsupported BZip2 design

**2020.2 v1.2.0**

* BZip2 instructions added back in

**2020.2 v1.1.0**

* Updated for 2020.2

  * ES1 and Production Versal silicon supported

  * New feature: Copy boot image to DDR

  * Temporarily removed BZip2 instructions until design is ready

**2019.2 v1.0.2:**

* Sphinx documentation template changes

**2019.2 v1.0.1:**

* Added support for VMK180

* Changed to UART1 in Bzip Concept Diagram

**2019.2 v1.0.0:**

* Compatible with Vivado and PetaLinux 2019.2 tools version

* Initial Release of Subsystem Restart TRD including:

  * Vivado design

  * PetaLinux BSP

  * Prebuilt SD card image

  * Jupyter notebooks

  * Baseline and BZip2 designs

