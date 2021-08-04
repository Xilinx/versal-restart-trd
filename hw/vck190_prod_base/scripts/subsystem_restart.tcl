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

create_bd_design versal_restart_trd

update_compile_order -fileset sources_1

create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips versal_cips_0

apply_bd_automation -rule xilinx.com:bd_rule:cips \
	-config { \
		board_preset {Yes} \
		boot_config {Custom} \
		configure_noc {Add new AXI NoC} \
		debug_config {JTAG} \
		design_flow {Full System} \
		mc_type {DDR} \
		num_mc {1} \
		pl_clocks {1} \
		pl_resets {1} \
	}  [get_bd_cells versal_cips_0]

validate_bd_design
save_bd_design

# Set CIPS params for NCI ports
set_property -dict [list \
	CONFIG.PS_PMC_CONFIG { \
	  PS_USE_FPD_AXI_NOC0 1 \
      	  PS_USE_FPD_AXI_NOC1 1 \
        } ] \
[get_bd_cells versal_cips_0]

# Configure NOC for new ports
set_property -dict [list CONFIG.NUM_SI {8} CONFIG.NUM_CLKS {8}] [get_bd_cells axi_noc_0]
set_property -dict [list CONFIG.CATEGORY {ps_nci} CONFIG.CONNECTIONS {MC_1 { read_bw {1720} write_bw {1720} read_avg_burst {4} write_avg_burst {4}} }] [get_bd_intf_pins /axi_noc_0/S06_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_nci} CONFIG.CONNECTIONS {MC_2 { read_bw {1720} write_bw {1720} read_avg_burst {4} write_avg_burst {4}} }] [get_bd_intf_pins /axi_noc_0/S07_AXI]
set_property -dict [list CONFIG.ASSOCIATED_BUSIF {S06_AXI}] [get_bd_pins /axi_noc_0/aclk6]
set_property -dict [list CONFIG.ASSOCIATED_BUSIF {S07_AXI}] [get_bd_pins /axi_noc_0/aclk7]

# Connect new ports between CIPS and NOC
connect_bd_intf_net [get_bd_intf_pins versal_cips_0/FPD_AXI_NOC_0] [get_bd_intf_pins axi_noc_0/S06_AXI]
connect_bd_intf_net [get_bd_intf_pins versal_cips_0/FPD_AXI_NOC_1] [get_bd_intf_pins axi_noc_0/S07_AXI]
connect_bd_net [get_bd_pins versal_cips_0/fpd_axi_noc_axi0_clk] [get_bd_pins axi_noc_0/aclk6]
connect_bd_net [get_bd_pins versal_cips_0/fpd_axi_noc_axi1_clk] [get_bd_pins axi_noc_0/aclk7]

assign_bd_address
validate_bd_design
save_bd_design

# Set pl clock, FPD master, IPI
set_property -dict [list \
	CONFIG.PS_PMC_CONFIG { \
      	  PS_USE_M_AXI_FPD 1 \
      	  PMC_CRP_PL0_REF_CTRL_FREQMHZ 100 \
	  PS_GEN_IPI0_ENABLE 1  \
	  PS_GEN_IPI1_ENABLE 1  \
	  PS_GEN_IPI2_ENABLE 1  \
	  PS_GEN_IPI3_ENABLE 1  \
	  PS_GEN_IPI4_ENABLE 1  \
	  PS_GEN_IPI5_ENABLE 1  \
	  PS_GEN_IPI6_ENABLE 1  \
      	} \
] [get_bd_cells versal_cips_0]

# Set GPIO EMIO, UART_1, IPI Master, I2C0
set_property -dict [list \
	CONFIG.PS_PMC_CONFIG { \
      	  PS_GEN_IPI1_MASTER {R5_0} \
      	  PS_GEN_IPI2_MASTER {R5_1} \
      	  PS_GPIO_EMIO_PERIPHERAL_ENABLE {1} \
      	  PS_GPIO_EMIO_WIDTH {3}	\
      	  PS_I2C0_PERIPHERAL {ENABLE {1} IO {PMC_MIO 46 .. 47}} \
      	  PS_TTC1_PERIPHERAL_ENABLE {1} \
      	  PS_TTC2_PERIPHERAL_ENABLE {1} \
      	  PS_TTC3_PERIPHERAL_ENABLE {1} \
	  PS_UART1_PERIPHERAL {{ENABLE 1} {IO EMIO}} \
	} \
] [get_bd_cells versal_cips_0]


# Enable WWDT0/1
set_property -dict [list \
	CONFIG.PS_PMC_CONFIG { \
 	  PS_WWDT0_CLK {{ENABLE 1} {IO APB}}  \
	  PS_WWDT0_PERIPHERAL {{ENABLE 1} {IO EMIO}}  \
	  PS_WWDT1_CLK {{ENABLE 0} {IO APB}}  \
	  PS_WWDT1_PERIPHERAL {{ENABLE 1} {IO EMIO}} \
	} \
] [get_bd_cells versal_cips_0]


# Enable coherency
set_property -dict [list CONFIG.PS_PMC_CONFIG {PMC_SD1_COHERENCY 0}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_USB_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_GEM0_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_GEM1_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_LPDMA0_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_LPDMA1_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_LPDMA2_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_LPDMA3_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_LPDMA4_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_LPDMA5_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_LPDMA6_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_LPDMA7_COHERENCY 1}] [get_bd_cells /versal_cips_0]
set_property -dict [list CONFIG.PS_PMC_CONFIG {PS_RPU_COHERENCY 0}] [get_bd_cells /versal_cips_0]

# Create instance: pl_subsystem
create_hier_cell_pl_subsystem [current_bd_instance .] pl_subsystem

# Create ports
set UART_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_1 ]


# Create interface connections
connect_bd_intf_net -intf_net versal_cips_0_UART1 [get_bd_intf_ports UART_1] [get_bd_intf_pins versal_cips_0/UART1]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins pl_subsystem/S00_AXI] [get_bd_intf_pins versal_cips_0/M_AXI_FPD]

# Create port connections

connect_bd_net [get_bd_pins versal_cips_0/pl0_ref_clk] [get_bd_pins pl_subsystem/clk]
connect_bd_net [get_bd_pins versal_cips_0/pl0_ref_clk] [get_bd_pins versal_cips_0/m_axi_fpd_aclk]
connect_bd_net -net versal_cips_0_lpd_gpio_o [get_bd_pins versal_cips_0/lpd_gpio_o] [get_bd_pins pl_subsystem/Din]
connect_bd_net -net versal_cips_0_pl0_resetn [get_bd_pins pl_subsystem/ext_reset_in] [get_bd_pins versal_cips_0/pl0_resetn]
connect_bd_net -net xlconcat_0_dout [get_bd_pins versal_cips_0/lpd_gpio_i] [get_bd_pins pl_subsystem/dout]

# Create address segments
assign_bd_address [get_bd_addr_segs *]

