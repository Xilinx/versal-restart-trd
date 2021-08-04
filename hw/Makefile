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
# Makefile to build hardware design of Versal Restart TRD project
#

_PWD := $(shell readlink -f .)

#default Parameter Optioins for local build if not passed from TOP makefile
BOARD := vck190
SIL := prod
DESIGN := base
BUILD_DIR := $(_PWD)/build
DEPLOY_DIR :=  $(_PWD)/output

DEST_DIR := $(DEPLOY_DIR)/reference_images

IP_REPO_LINK := $(BUILD_DIR)/../ip_repo
XSA_FILE := $(BUILD_DIR)/vivado/versal_restart_trd.runs/impl_1/versal_restart_trd_wrapper.xsa
PDI_FILE := $(BUILD_DIR)/vivado/versal_restart_trd.runs/impl_1/versal_restart_trd_wrapper.pdi
SRCS := $(_PWD)/$(BOARD)_$(SIL)_$(DESIGN)
IP_REPO := $(_PWD)/ip_repo

VCK190_ES1_DEVICE="xcvc1902-*"
VMK180_ES1_DEVICE="xcvm1802-*"

ES1_DEVICE_LIST=$(VCK190_ES1_DEVICE) $(VMK180_ES1_DEVICE)
VIVADO_INIT_FILE=$(HOME)/.Xilinx/Vivado/Vivado_init.tcl

# commands
COPY := cp -rfL
REMOVE := rm -rf

# dependency tracker
SRCS_DEP := $(shell find $(_PWD)/common $(IP_REPO) $(SRCS) -type f)

# Check if vivado env is invoked.
ifeq ($(shell which vivado >/dev/null 2>&1; echo $$?), 1)
$(error The vivado enviroment is not set)
endif

all: deploy

.PHONY: deploy
deploy: $(XSA_FILE) $(PDI_FILE) | $(DEST_DIR)
	@$(COPY) $(XSA_FILE) $(PDI_FILE) $(DEST_DIR)

.PHONY: build_design
build_design: $(XSA_FILE)
$(XSA_FILE): $(PDI_FILE)

$(PDI_FILE):  $(SRCS_DEP) | $(SRCS) $(BUILD_DIR) $(IP_REPO_LINK) check_env
	@echo "Building hw design"
	@$(COPY) $(SRCS)/* $(BUILD_DIR)
	cd $(BUILD_DIR); vivado -mode batch -source scripts/build_all.tcl

$(BUILD_DIR) $(DEST_DIR):
	@mkdir -p $@

.PHONY:
check_env: $(ES1_DEVICE_LIST)

$(ES1_DEVICE_LIST): $(VIVADO_INIT_FILE)
	@grep -qxF "enable_beta_device $@" $(VIVADO_INIT_FILE) || echo "enable_beta_device $@" >> $(VIVADO_INIT_FILE)

$(VIVADO_INIT_FILE):
	@mkdir -p $(dir $(VIVADO_INIT_FILE))
	@touch $(VIVADO_INIT_FILE)

# Experimental. Replace softlink with copy or hardlink, if any issue.
$(IP_REPO_LINK): $(IP_REPO)
	@ln -s $< $@

.PHONY: clean
clean:
	-@$(REMOVE) $(BUILD_DIR) $(IP_REPO_LINK)

