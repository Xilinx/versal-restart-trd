.. _build_sw:

Build Software
==============

Prerequisites
-------------

* Vitis Unified Software Platform 2022.1

* PetaLinux Tools 2022.1

* Linux host machine (All instructions are with Linux host machine)

* VCK190 or VMK180 Evaluation Board

.. note:: Instructions on this page are applicable to both VCK190 and VMK180 developement boards. Use appropriate XSA file for the build.

Sources
-------

Sources necessary to build hardware and software components of the TRD are available in git repository.

Clone the git repository for the current release tag.
::

  # Create and move to directory where the source repository is to be cloned
  mkdir -p </path/to/source/repo>
  cd </path/to/source/repo>

  # clone and switch to current release tag (xilinx-v2021.2)
  git clone https://github.com/Xilinx/versal-restart-trd.git
  git checkout -b xilinx-v2021.2 xilinx-v2021.2

For rest of the documentation, path to the root of this repository will be referred as $REPO_SRC.

.. note:: REPO_SRC = </path/to/source/repo>/versal-restart-trd

$REPO_SRC/sw directory provides sources to build following components:

* RPU application
* Petalinux (Linux Images, rootfs, and BOOT Image artifacts)
* Boot and SD card image (BOOT.BIN and compressed wic image)

Automated Build with Makefile
-----------------------------

The repository provides Makefiles to build and copy hardware and software images to the deploy area.

Running :code:`make build_sw` builds the software components for the given configuration.

Here is an example build command for vck190 production board.
::

  cd $REPO_SRC
  make build_sw BAORD=vck190 SIL=prod DESIGN=base

As the XSA file is not explicitly provided in above command, the build looks for the xsa file at *output/vck190-prod-base/reference_images/versal_restart_trd_wrapper.xsa*. If the file is not present here, the build triggers the hardware build to generate the xsa file before building the software.

Here is the output for the above build.
::

  output/
  └── vck190-prod-base
      ├── petalinux-sdimage.wic.xz  #SD card image
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

It is also possible to provide the XSA file explicitly by XSA_FILE option.
::

  make BOARD=vmk180 SIL=prod XSA_FILE=/scratch/build-area/hw/new.xsa'

This produces
::

  output/
  └── vmk180-prod-base
      ├── petalinux-sdimage.wic.xz
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
          └── u-boot.elf

Run :code:`make help` in *$REPO_SRC* directory to see various build options.

For more details on usage of Makefile refer the `README.md <https://github.com/Xilinx/versal-restart-trd/blob/xilinx-v2021.2/README.md#makefiles>`_ file in the repository.

Build without Makefile
----------------------

This section provides instruction to build individual software components through Vitis and Petalinux flow without automated Makefile.

Following components will be built:

* RPU application
* Petalinux (Linux Images, Rootfs, and BOOT Image artifacts)
* Boot and SD card image (BOOT.BIN and compressed wic image)

Choose a workspace area (with more than 50GB of free space). Lets call that area as **$VSSR_WS**.

Build RPU Application
*********************

#. On Linux, set up the Vivado environment in a terminal window by sourcing
   <Vitis_install_path>/settings64.sh

#. Launch the Vitis Unified Software Platform::

        vitis -workspace $VSSR_WS/rpu_ws

#. From the Welcome screen or *File -> New* menu select *Create Application Project*

   .. figure:: images/rpu_app_build/01_welcome.png
     :width: 50%
     :align: center
     :alt: vitis_welcome

#. Platform: Select *Create a new platform from hardware (XSA)*, then browse and select the hardware XSA file to be used and press *Next*.

   .. figure:: images/rpu_app_build/03_platform_1.png
     :width: 50%
     :align: center
     :alt: create_new_platform

   .. figure:: images/rpu_app_build/03_platform_2.png
     :width: 50%
     :align: center
     :alt: browse_xsa

   .. figure:: images/rpu_app_build/03_platform_3.png
     :width: 50%
     :align: center
     :alt: pick_xsa

#. Application Project Details: Add application name and select r5_0 for the target processor.

   .. figure:: images/rpu_app_build/05_app_details.png
     :width: 50%
     :align: center
     :alt: Application_Details

#. Domain Selection: Create new domain for r5 application to run standalone operating system (default).

   .. figure:: images/rpu_app_build/06_domain.png
     :width: 50%
     :align: center
     :alt: Domain_Details

#. Application Template: Choose *Empty Application(C)* and click *Finish*

   .. figure:: images/rpu_app_build/07_app_template.png
     :width: 50%
     :align: center
     :alt: Template

#. Navigate to BSP Settings and click *Modify BSP Settings*.

   .. figure:: images/rpu_app_build/08_bsp_nav.png
      :width: 50%
      :align: center
      :alt: bsp_nav

   .. figure:: images/rpu_app_build/09_bsp_page.png
      :width: 50%
      :align: center
      :alt: bsp_page

#. Select *libmetal* and *xilpm* libraries from the overview tab.

   .. figure:: images/rpu_app_build/10_lib_select.png
     :width: 50%
     :align: center
     :alt: lib

#. Change *stdin* and *stdout* to use UART1 instead of UART0 and press Ok to exit bsp settings.

   .. figure:: images/rpu_app_build/11_uart_select.png
     :width: 50%
     :align: center
     :alt: uart

#. Import Sources: Right click rpu_app and select *Import Sources...* (or do *File -> import* ) and import sources from ${REPO_SRC}/sw/standalone-srcs/rpu_app/src/ and click Finish.

   .. figure:: images/rpu_app_build/12_import_src_1.png
     :width: 50%
     :align: center
     :alt: import_sources

   .. figure:: images/rpu_app_build/12_import_src_2.png
     :width: 50%
     :align: center
     :alt: browse_sources

   .. figure:: images/rpu_app_build/12_import_src_3.png
     :width: 50%
     :align: center
     :alt: select_sources

   .. figure:: images/rpu_app_build/12_import_src_4.png
     :width: 50%
     :align: center
     :alt: import_sources_checkbox

#. Build all the projects (platform bsp and rpu_app) by clicking the build icon or by right clicking *rpu_app* in explorer pan and selecting *Build Project*

   .. figure:: images/rpu_app_build/13_build_1.png
     :width: 50%
     :align: center
     :alt: build_select_icon

   .. figure:: images/rpu_app_build/13_build_2.png
     :width: 50%
     :align: center
     :alt: build_select_menu

#. The application will be generated at::

   $VSSR_WS/rpu_ws/rpu_app/Debug/rpu_app.elf


For more detailed information on how to use Vitis, please refer to the `Vitis Documentation <http://www.xilinx.com/html_docs/xilinx2021_2/vitis_doc/>`_.

Generate Petalinux Image
************************

#. On Linux, set up the Petalinux environment in a terminal window by sourcing <Petalinux_install_path>/settings.sh

#. Create a new Petalinux project with versal template. Name it as plnx-vssr-trd
   ::

     cd $VSSR_WS
     petalinux-create -t project --template versal -n plnx-vssr-trd
     cd plnx-vssr-trd

#. Petalinux Hardware Configuration.

   * Point to the hardware XSA generated in the Build the Vivado Design section (or provided in the pre-built images). Below command picks the hw XSA from the workspace's vivado build area::

	 petalinux-config --get-hw-description=$VSSR_WS/hw_ws/vivado/versal_restart_trd.runs/impl_1/

   * Add The board/machine name in the *DTG Settings ---> MACHINE_NAME*, According to the following table

     ======== ============
     Board    Machine Name
     ======== ============
     VCK190   versal-vck190-reva-x-ebm-01-reva
     VMK180   versal-vmk180-reva-x-ebm-01-reva
     ======== ============

     .. figure:: images/plnx_build/plnx_config_1.png
       :width: 50%
       :align: center
       :alt: plnx_config_1

     .. figure:: images/plnx_build/plnx_config_2.png
       :width: 50%
       :align: center
       :alt: plnx_config_2

     .. figure:: images/plnx_build/plnx_config_3.png
       :width: 50%
       :align: center
       :alt: plnx_config_3

   * Change INITRAMFS/INITRD Image name to *petalinux-initramfs-image*. This will ensure to switch to rootfs on the sd card after initial boot from initramfs.

     .. figure:: images/plnx_build/plnx_img_pkg_1.png
       :width: 50%
       :align: center
       :alt: plnx_img_pkg_1

     .. figure:: images/plnx_build/plnx_img_pkg_2.png
       :width: 50%
       :align: center
       :alt: plnx_img_pkg_2

     .. figure:: images/plnx_build/plnx_img_pkg_3.png
       :width: 50%
       :align: center
       :alt: plnx_config_3

   * Save and Exit petalinux configuration

#. Configure Static IP using petalinux config, Petalinux Ethernet IP configuration (Optional. Default=DHCP)
   ::

     petalinux-config

   * Select *Subsystem AUTO Hardware Settings ---> Ethernet Settings ---> Primary Ethernet ---> ethernet_0*

   .. figure:: images/plnx_build/plnx_ip_config_1.png
     :width: 50%
     :align: center
     :alt: plnx_ip_config_1

   * Unselect *Obtain IP address automatically* and set the static IP

   .. figure:: images/plnx_build/plnx_ip_config_2.png
     :width: 50%
     :align: center
     :alt: plnx_ip_config_2

   * Save and Exit petalinux configuration

#. Add vssr-trd yocto layer
   ::

     # Copy the layer sources
     cp -rf $REPO_SRC/sw/yocto-layers/meta-vssr-trd project-spec/
     # Add Yocto layer in the petalinux configuration
     petalinux-config

   * Add new user layer and enter the layer path at *Yocto Settings ---> User Layers ---> user layer 0*

     .. figure:: images/plnx_build/plnx_layer_add_2.png
       :width: 50%
       :align: center
       :alt: plnx_layer_add_2

     .. figure:: images/plnx_build/plnx_layer_add_3.png
       :width: 50%
       :align: center
       :alt: plnx_layer_add_3

   * Save and Exit petalinux configuration

#. Add layer to include artifacts in the build::

   ./project-spec/meta-vssr-trd/scripts/add-layer.sh

#. Build the Petalinux project::

    petalinux-build

#. Output images are generated in following directory::

    ${VSSR_WS}/plnx-vssr-trd/images/linux


Create BOOT.BIN
***************

Perform the following steps in a Linux shell with Petalinux environment configured.

#. Navigate to Petalinux project root::

        cd ${VSSR_WS}/plnx-vssr-trd/

#. Copy RPU application elf built in previous section to current directory::

        cp $VSSR_WS/rpu_ws/rpu_app/Debug/rpu_app.elf .

#. Build the BOOT.BIN using the bif available in the meta-vssr-trd::

        petalinux-package --boot --bif project-spec/meta-vssr-trd/scripts/bif_files/boot.bif

Create Create SD card wic image
*******************************

Following step create a SD card wic image which can be flashed on the uSD card for the target board.

#. Navigate to Petalinux project root::

        cd ${VSSR_WS}/plnx-vssr-trd/

#. Create wic image::

        petalinux-package --wic --wic-extra-args "-c xz"

#. This will create the compressed wic image at following location::

        ${VSSR_WS}/plnx-vssr-trd/images/linux/petalinux-sdimage.wic.xz

The resulting build artifacts will be available in the *images/linux/*

Refer the "Run Images on Target" section for how to flash the SD Card and boot the TRD images.

For more detailed information on how to use Petalinux, please refer to the `Petalinux Tool Reference Guide <https://www.xilinx.com/support/documentation/sw_manuals/xilinx2021_2/ug1144-petalinux-tools-reference-guide.pdf>`_.
