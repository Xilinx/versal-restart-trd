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
# Makefile for Versal Restart TRD project
#

#Makefile location
_PWD := $(shell readlink -f .)

# You can set these variable from the command line
BOARD		:= vck190
SIL			:= prod
DESIGN		:= base
BUILD_DIR	:= $(_PWD)/build
#
# Make Following variables available for sub makes
export BOARD SIL DESIGN

# Internal Variables
# Valid Option Lists
_BOARD_LIST		:= vck190 vmk180
_SIL_LIST		:= prod
_DESIGN_LIST	:= base

# Workspaces
DOC_WORKSPACE := $(BUILD_DIR)/docs
WORKSPACE_DIR := $(BUILD_DIR)/$(BOARD)-$(SIL)-$(DESIGN)

# Deploy Area
DEPLOY_TOP := $(_PWD)/output
DEPLOY_DIR := $(_PWD)/output/$(BOARD)-$(SIL)-$(DESIGN)

# XSA file
XSA_FILE := $(DEPLOY_DIR)/reference_images/versal_restart_trd_wrapper.xsa

# SD image
WIC_IMAGE := $(DEPLOY_DIR)/petalinux-sdimage.wic.xz

# Commands
DEPLOY = cp -r
REMOVE = rm -rf

# dependency tracking
_HW_SRCS_DEP := $(shell find hw -type f)
_SW_SRCS_DEP := $(shell find sw -type f)

#define newline
define nl


endef

# Check if the correct options are set.
#Check for valid board
ifeq ($(filter $(BOARD),$(_BOARD_LIST)),)
$(error Invalid parameter BOARD=$(BOARD).$(nl)Valid Options: $(_BOARD_LIST).$(nl)Use 'make help' to see all options)
endif
#Check for valid silicon
ifeq ($(filter $(SIL),$(_SIL_LIST)),)
$(error Invalid parameter SIL=$(SIL).$(nl)Valid Options: $(_SIL_LIST).$(nl)Use 'make help' to see all options)
endif
#Check for valid design
ifeq ($(filter $(DESIGN),$(_DESIGN_LIST)),)
$(error Invalid parameter DESIGN=$(DESIGN).$(nl)Valid Options: $(_DESIGN_LIST).$(nl)Use 'make help' to see all options)
endif

.PHONY: all
all: build_sdcard

.PHONY: help
help:
	@echo ''
	@echo 'Usage: make [<target>] [<Option1>=<val1> [<Option2>=<val2>]...]'
	@echo ''
	@echo ''
	@echo 'Builds various design artifacts and deploy it in ./output directory'
	@echo ''
	@echo 'Each run is specific to the given build-config. The config is represented by'
	@echo 'combination of <board-silicon-design>'
	@echo ''
	@echo 'Target:'
	@echo '    build_sdcard          Default make target. Same as build_sw.'
	@echo '    build_sw              Builds the software images and wic image for flashing sd card.'
	@echo '    build_hw              Builds hardware images.'
	@echo '    build_docs            Generate html documentation using sphinx.'
	@echo '    clean                 Clean the build area for sw and hw for the given build-config (use clean_hw or clean_sw for partial cleanup).'
	@echo '    nuke                  Remove build and deploy(output) area completely for given config.'
	@echo '    nuke_all              Remove build and deploy(output) area completely for all config.'
	@echo ''
	@echo 'Options:'
	@echo '    BOARD=<val>           Choose board variant. Impacts all targets expect build_docs.'
	@echo '                          Possible Values: ${_BOARD_LIST} (default: ${BOARD})'
	@echo ''
	@echo '    SIL=<val>             Choose silicon variant. Impacts all targets expect build_docs.'
	@echo '                          Possible Values: ${_SIL_LIST} (default: ${SIL})'
	@echo ''
	@echo '    DESIGN=<val>          Choose design variant. Impacts all targets expect build_docs.'
	@echo '                          Possible Values: ${_DESIGN_LIST} (default: ${DESIGN})'
	@echo ''
	@echo "    BUILD_DIR=<path>      Build directory path (default: ./build). Impacts all targets."
	@echo ''
	@echo '    XSA_FILE=<file>       Custom XSA file (with full path) to be used for sw build. Impacts only build_sw target.'
	@echo '                          (default: ./output/<build-config>/reference_images/versal_restart_trd_wrapper.xsa)'
	@echo '                          If default xsa file does not exist and no XSA_FILE is provided,'
	@echo '                          build_hw target is automatically invoked to build hardware.'
	@echo ''
	@echo 'Examples:'
	@echo ''
	@echo '    Build with default settings. Generates hw and sw images for ${BOARD}-${SIL}-${DESIGN} build config'
	@echo '           make'
	@echo ''
	@echo '    Generates hw and sw images for vmk180-prod-base build config'
	@echo '           make BOARD=vmk180'
	@echo ''
	@echo '    Generates hw images for vck190-prod-base build config'
	@echo '           make build_hw BOARD=vck190'
	@echo ''
	@echo '    Generates sphinx documentation'
	@echo '           make build_docs'
	@echo ''
	@echo '    Generates hw and sw images for vck190-prod-base build config, but use the /tmp/build-area'
	@echo '           make BOARD=vck190 SIL=prod BUILD_DIR=/tmp/build-area'
	@echo ''
	@echo '    Generates sw images for vmk180-prod-base build config using the pre generated custom xsa file'
	@echo '           make BOARD=vmk180 DESIGN=base XSA_FILE=/scratch/build-area/hw/new.xsa'
	@echo ''
	@echo ''

.PHONY: build_sdcard
build_sdcard: build_sw

.PHONY: build_sw
build_sw: $(WIC_IMAGE)
$(WIC_IMAGE): $(XSA_FILE) $(_SW_SRCS_DEP) | sw
	$(MAKE) -C sw BUILD_DIR=$(WORKSPACE_DIR)/sw DEPLOY_DIR=$(DEPLOY_DIR) XSA_FILE=$(XSA_FILE)

.PHONY: build_hw
build_hw: $(XSA_FILE)
$(XSA_FILE): $(_HW_SRCS_DEP) | hw
	$(MAKE) -C hw BUILD_DIR=$(WORKSPACE_DIR)/hw DEPLOY_DIR=$(DEPLOY_DIR)

.PHONY: build_docs
build_docs: | docs $(DEPLOY_TOP)
	$(MAKE) -C docs clean BUILDDIR=$(DOC_WORKSPACE)
	$(MAKE) -C docs html BUILDDIR=$(DOC_WORKSPACE)
	-@$(REMOVE) $(DEPLOY_TOP)/docs
	@$(DEPLOY) $(DOC_WORKSPACE)/html $(DEPLOY_TOP)/docs

.PHONY: publish
publish: build_docs docs/description
	-@$(REMOVE) $(DEPLOY_TOP)/docs
	git clone --branch gh-pages $(shell git config --get remote.origin.url | xargs echo) $(DEPLOY_TOP)/docs
	rsync -a --delete --exclude .git/ $(DOC_WORKSPACE)/html/ $(DEPLOY_TOP)/docs/
	git -C $(DEPLOY_TOP)/docs add $(DEPLOY_TOP)/docs
	git -C $(DEPLOY_TOP)/docs commit -s --file $(_PWD)/docs/description
	#change the gh-pages-rc to gh-pages, when ready
	git -C $(DEPLOY_TOP)/docs push origin gh-pages:gh-pages-rc

$(DEPLOY_TOP):
	@mkdir -p $@

.PHONY: clean
clean: clean_sw clean_hw
	$(MAKE) -C docs clean BUILDDIR=$(DOC_WORKSPACE)

clean_%: %
	$(MAKE) -C $< clean BUILD_DIR=$(WORKSPACE_DIR)/$<

.PHONY: nuke
nuke:
	-@$(REMOVE) $(DOC_WORKSPACE) $(WORKSPACE_DIR) $(DEPLOY_DIR) $(DEPLOY_TOP)/docs

.PHONY: nuke_all
nuke_all:
	-@$(REMOVE) $(BUILD_DIR) $(DEPLOY_TOP)

