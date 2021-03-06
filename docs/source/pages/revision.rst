Revision History
================
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

  * Changed Release format: Source on Github and Binaries on Xilinx.com through zip file.

  * New features: Healthy Boot, Recovery with WDT, CDO Overlay

  * Improved Jupyter dashboard layout.

  * RPU now demonstrate all the features like APU.

  * Removed unsupported BZip2 design.

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

