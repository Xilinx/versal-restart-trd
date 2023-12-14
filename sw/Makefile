#*****************************************************************************
#
# Copyright (C) 2019 - 2021 Xilinx, Inc.  All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
#******************************************************************************
#
# Makefile to build software components of Versal Restart TRD project
#

_PWD := $(shell readlink -f .)

# Default parameter optioins for local build if not passed from TOP makefile
BOARD := vck190
SIL := prod
DESIGN := base
BUILD_DIR := $(_PWD)/build
DEPLOY_DIR :=  $(_PWD)/output

XSA_FILE := $(DEPLOY_DIR)/reference_images/versal_restart_trd_wrapper.xsa

RPU_SRC := standalone-srcs/rpu_app/src
RPU_WS := $(BUILD_DIR)/rpu_ws
RPU_APP := $(RPU_WS)/rpu_app/Debug/rpu_app.elf

YOCTO_SRCS := yocto-layers
PLNX_PROJECT := $(BUILD_DIR)/plnx-$(BOARD)-$(SIL)
PLNX_PROJECT_SPEC := $(PLNX_PROJECT)/project-spec
PLNX_IMG_DIR := $(PLNX_PROJECT)/images/linux

BIF_FILE = $(PLNX_PROJECT_SPEC)/meta-vssr-trd/scripts/bif_files/$(BOARD)/boot.bif

YOCTO_LAYER_base := meta-vssr-trd

PLNX_BOOT = $(PLNX_IMG_DIR)/BOOT.BIN
PLNX_BOOT_OBJS += $(PLNX_IMG_DIR)/bl31.elf
PLNX_BOOT_OBJS += $(PLNX_IMG_DIR)/plm.elf
PLNX_BOOT_OBJS += $(PLNX_IMG_DIR)/psmfw.elf
PLNX_BOOT_OBJS += $(PLNX_IMG_DIR)/u-boot.elf
PLNX_BOOT_OBJS += $(PLNX_IMG_DIR)/system.dtb
PLNX_BOOT_ARGS = --bif $(BIF_FILE) --qemu-rootfs no --force

PLNX_WIC = $(PLNX_IMG_DIR)/petalinux-sdimage.wic.xz
PLNX_WIC_OBJS += $(PLNX_IMG_DIR)/boot.scr
PLNX_WIC_OBJS += $(PLNX_IMG_DIR)/Image
PLNX_WIC_OBJS += $(PLNX_IMG_DIR)/rootfs.tar.gz
PLNX_WIC_OBJS += $(PLNX_IMG_DIR)/ramdisk.cpio.gz.u-boot
PLNX_WIC_ARGS = --wic-extra-args "-c xz"

PLNX_CONFIG := $(PLNX_PROJECT_SPEC)/hw-description/system.xsa

DEPLOY_IMG = $(PLNX_WIC)
DEPLOY_REF = $(PLNX_BOOT)
DEPLOY_REF += $(PLNX_BOOT_OBJS)
DEPLOY_REF += $(PLNX_WIC_OBJS)
DEPLOY_REF += $(BIF_FILE)
DEPLOY_REF += $(RPU_APP)
DEPLOY_REF_DIR = $(DEPLOY_DIR)/reference_images

# commands
COPY := cp -rf
REMOVE := rm -rf

# dependency tracking
YOCTO_LAYER_DEP_base := $(shell find $(YOCTO_SRCS)/$(YOCTO_LAYER_base) -type f)
RPU_SRC_DEP := $(shell find $(RPU_SRC) -type f)

# Check if Petalinux env is invoked.
ifeq ($(shell which petalinux-build >/dev/null 2>&1; echo $$?), 1)
$(error The Petalinux enviroment is not set)
endif
# Check if xsct env is invoked.
ifeq ($(shell which xsct >/dev/null 2>&1; echo $$?), 1)
$(error The vitis enviroment is not set; required for xsct)
endif

.PHONY: all
all: deploy

.PHONY: deploy
deploy: $(DEPLOY_IMG) $(DEPLOY_REF) $(DEPLOY_REF_DIR)
	@$(COPY) $(DEPLOY_IMG) $(DEPLOY_DIR)/
	@$(COPY) $(DEPLOY_REF) $(DEPLOY_REF_DIR)/

.PHONY: wic
wic: $(PLNX_WIC)
$(PLNX_WIC): $(PLNX_WIC_OBJS) $(PLNX_BOOT)
	@echo "Building wic image"
	cd $(PLNX_PROJECT); petalinux-package --wic $(PLNX_WIC_ARGS)

.PHONY: boot
boot: $(PLNX_BOOT)
$(PLNX_BOOT): $(PLNX_BOOT_OBJS) $(RPU_APP)
	@echo "Building BOOT.BIN"
	# script to generate boot.bin
	$(COPY) $(RPU_APP) $(PLNX_PROJECT)
	cd $(PLNX_PROJECT); petalinux-package --boot $(PLNX_BOOT_ARGS)

.PHONY: image
image $(PLNX_BOOT_OBJS) $(PLNX_WIC_OBJS): $(PLNX_PROJECT_SPEC)/$(YOCTO_LAYER_$(DESIGN)) $(PLNX_PROJECT_SPEC)
	@echo 'Build PetaLinux image'
	petalinux-build -p $(PLNX_PROJECT)

$(RPU_APP): $(RPU_SRC_DEP)
	@echo "Building RPU Application"
	-@$(REMOVE) $(RPU_WS)
	xsct $(_PWD)/scripts/rpu_build.tcl $(RPU_WS) $(XSA_FILE) $(RPU_SRC)

$(PLNX_PROJECT): | $(BUILD_DIR)
	@echo 'Creating Project'
	cd $(dir $(PLNX_PROJECT)); petalinux-create -t project --template versal -n $(notdir $(PLNX_PROJECT))
	$(_PWD)/scripts/plnx-cfg -p $(PLNX_PROJECT) -b $(BOARD)

$(PLNX_CONFIG): $(XSA_FILE) | $(PLNX_PROJECT)
	@echo 'Configuring Petalinux project'
	petalinux-config -p $(PLNX_PROJECT) --silentconfig --get-hw-description=$(dir $(XSA_FILE))

$(PLNX_PROJECT_SPEC)/$(YOCTO_LAYER_base): $(PLNX_CONFIG) $(YOCTO_LAYER_DEP_base) | $(YOCTO_SRCS)/$(YOCTO_LAYER_base)
	@echo 'Layer: $@'
	-@$(REMOVE) $(PLNX_PROJECT_SPEC)/$(YOCTO_LAYER_base)
	$(COPY) $(YOCTO_SRCS)/$(YOCTO_LAYER_base) $(PLNX_PROJECT_SPEC)/
	@$(PLNX_PROJECT_SPEC)/$(YOCTO_LAYER_base)/scripts/add-layer.sh

$(BUILD_DIR) $(DEPLOY_REF_DIR):
	@mkdir -p $@

.PHONY: clean
clean:
	-@$(REMOVE) $(BUILD_DIR)

