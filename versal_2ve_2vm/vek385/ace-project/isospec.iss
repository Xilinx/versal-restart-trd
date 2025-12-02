{
  "spec_file_version": 4,
  "info": {
    "arch_data_version": 100,
    "device_name": "2ve3858",
    "settings_file": "default_settings",
    "settings_suffix": "psxc-pmxc",
    "format": "shallow"
  },
  "flags": {"debugger_access": true, "enable_protection": false, "write_subsystems": true},
  "default_settings": {
    "flags": {"debugger_access": true, "enable_protection": true, "write_subsystems": true},
    "base_protection": {
      "access": [
        {
          "name": "firmware_and_cci",
          "comment": "root-access for memory, opens SMID 0 for CCI cache write-back",
          "type": "smid_list",
          "SMIDs": ["FPD_CCI", "PMC_DMA", "RCU_and_PPU"]
        },
        {
          "name": "firmware_and_cci.debug",
          "comment": "root-access for memory, opens SMID 0 for CCI cache write-back",
          "type": "smid_list",
          "SMIDs": ["DAP_and_DPC", "FPD_CCI", "PMC_DMA", "RCU_and_PPU"]
        },
        {
          "name": "firmware",
          "comment": "Firmware masters, used as a masters list for protection unit root-access",
          "type": "smid_list",
          "SMIDs": ["PMC_DMA", "RCU_and_PPU"]
        },
        {
          "name": "firmware.debug",
          "comment": "Firmware masters, used for root-access if debugger_access is enabled",
          "type": "smid_list",
          "SMIDs": ["DAP_and_DPC", "PMC_DMA", "RCU_and_PPU"]
        },
        {
          "name": "apu_gic_dist",
          "comment": "All APU cores can access these as read/write",
          "destinations": ["APU_GIC_DIST_ALIAS", "APU_GIC_DIST_MAIN", "APU_GIC_DIST_MB_ALIAS"],
          "SMIDs": ["APU"]
        },
        {
          "name": "apu_gic_redist_apu_rw",
          "comment": "APU_B cores can access these as read/write",
          "destinations": [
            "APU_GIC_DIST_ALIAS",
            "APU_GIC_ITS_CSR",
            "APU_GIC_REDIST_LPI0",
            "APU_GIC_REDIST_LPI1",
            "APU_GIC_REDIST_LPI2",
            "APU_GIC_REDIST_LPI3",
            "APU_GIC_REDIST_LPI4",
            "APU_GIC_REDIST_LPI5",
            "APU_GIC_REDIST_LPI6",
            "APU_GIC_REDIST_LPI7",
            "APU_GIC_REDIST_SGI0",
            "APU_GIC_REDIST_SGI1",
            "APU_GIC_REDIST_SGI2",
            "APU_GIC_REDIST_SGI3",
            "APU_GIC_REDIST_SGI4",
            "APU_GIC_REDIST_SGI5",
            "APU_GIC_REDIST_SGI6",
            "APU_GIC_REDIST_SGI7"
          ],
          "SMIDs": ["APU"]
        },
        {
          "name": "open_rw",
          "comment": "Any master can access these as read/write",
          "destinations": ["CoreSight", "IPI_buffers", "IPI_channels", "USB0_XHCI", "USB1_XHCI"],
          "SMIDs": ["ANY"]
        },
        {
          "name": "open_rw_2",
          "comment": "Any master can access these as read/write",
          "destinations": ["FPD_SMMU_CSR", "FPD_SMMU_TBU_CSR", "FPD_STM_CoreSight", "RPU_A_CSR", "RPU_B_CSR"],
          "SMIDs": ["ANY"]
        },
        {
          "name": "open_ro",
          "comment": "APU and ASU can access these as read-only",
          "destinations": ["CRP", "FPD_TSG_RO", "LPD_TSG_RO", "PMC_JTAG_CSR"],
          "flags": {"read_only": true},
          "SMIDs": ["APU", "ASU"]
        },
        {
          "name": "apu_rw_temp",
          "comment": "All APU cores can access these as read-write",
          "destinations": [
            "APU_GIC_ITS_CSR",
            "APU_PCIL",
            "CRF",
            "CRL",
            "FPD_TSG_RW",
            "PMC_GPIO"
          ],
          "SMIDs": ["APU"]
        },
        {
          "name": "apu_core_rw",
          "comment": "APU cores can access these as read-write",
          "destinations": [
            "APU_A",
            "APU_B",
            "APU_C",
            "APU_D",
            "OCM0_CSR",
            "OCM1_CSR",
            "OCM2_CSR",
            "OCM3_CSR"
          ],
          "SMIDs": ["APU"]
        },
        {
          "name": "bootmedia",
          "comment": "Allow booting from different boot media",
          "destinations": ["CFU_STREAM", "OSPI_mem", "PMC_RAM_mem", "PPU", "RPU_TCM"],
          "SMIDs": ["OSPI", "QSPI", "SD", "eMMC"]
        },
        {
          "name": "PLM_image_store",
          "comment": "Destination for PLM image store",
          "SMIDs": ["PMC_DMA", "RCU_and_PPU"]
        },
        {
          "name": "PLM_in_place_update",
          "comment": "Destination for PLM in-place update",
          "SMIDs": ["PMC_DMA", "RCU_and_PPU"]
        },
        {
          "name": "PMC_ASU_RAM",
          "comment": "Firmware access to ASU Instruction and Data RAM",
          "destinations": ["ASU_RAM_DATA", "ASU_RAM_INSTR"],
          "SMIDs": ["PMC_DMA", "RCU_and_PPU"]
        },
        {
          "name": "PMC_ASU",
          "comment": "Firmware access to ASU XMPU and Global Register",
          "destinations": ["ASU_GLOBAL", "ASU_XMPU"],
          "SMIDs": ["PMC_DMA", "RCU_and_PPU"]
        },
        {
          "name": "ASU",
          "destinations": [
            "ASU_ECC",
            "ASU_INT",
            "ASU_IO_DMA",
            "ASU_MDM",
            "ASU_PL_CSR",
            "ASU_RAM_DATA_ECC_CTRL",
            "ASU_RAM_INSTR_ECC_CTRL",
            "ASU_RSA",
            "ASU_SHA2",
            "ASU_SHA3",
            "ASU_TMR_INJECT",
            "ASU_TMR_MANAGER",
            "ASU_TRNG",
            "ASU_TRNG_AXI"
          ],
          "flags": {"no_root_access": true},
          "SMIDs": ["ASU_DMA0", "ASU_DMA1", "ASU_RISC_V"]
        },
        {
          "name": "ASU_PLM",
          "comment": "ASU access to PLM RTCA",
          "destinations": ["PLM_RTCA"],
          "flags": {"read_only": true},
          "SMIDs": ["ASU_DMA0", "ASU_DMA1", "ASU_RISC_V"]
        },
        {
          "name": "ASU_XMPU",
          "comment": "ASU access to RAM Instruction, Data and TRACE",
          "destinations": ["ASU_RAM_DATA", "ASU_RAM_INSTR", "ASU_TMR_TRACE"],
          "SMIDs": ["ASU_DMA0", "ASU_DMA1", "ASU_RISC_V"]
        },
        {
          "name": "ASU_key_vault",
          "comment": "Destination for ASU key vault. Encryption mode: GCM",
          "flags": {"exclusive_access": true, "gcm": true},
          "SMIDs": ["ASU"]
        },
        {
          "name": "ASU_UART",
          "comment": "ASU access to UART",
          "destinations": ["UART0"],
          "SMIDs": ["ASU"]
        },
        {
          "name": "ASU_PMC",
          "comment": "ASU access to eFuse cache, IPI_channels and PMC Global",
          "destinations": ["IPI_channels", "PMC_EFUSE_CACHE", "PMC_GLOBAL"],
          "flags": {"read_only": true},
          "SMIDs": ["ASU"]
        },
        {
          "name": "ISP_TILE0_INST0",
          "comment": "ISP Tile 0 Instance 0",
          "destinations": ["ISP0_CSR0", "ISP_TILE0_IBA_INST0", "ISP_TILE0_OBA_INST0", "ISP_TILE0_SLCR_GEN", "ISP_TILE0_SLCR_INST0"],
          "flags": {"ignore": true, "tool_managed": true}
        },
        {
          "name": "ISP_TILE0_dynamic",
          "comment": "ISP Tile 0 Dynamic",
          "destinations": ["ISP_TILE0_IBA_dynamic"],
          "flags": {"ignore": true, "tool_managed": true}
        },
        {
          "name": "ISP_TILE0_INST1",
          "comment": "ISP Tile 0 Instance 1",
          "destinations": ["ISP0_CSR1", "ISP_TILE0_IBA_INST1", "ISP_TILE0_OBA_INST1", "ISP_TILE0_SLCR_GEN"],
          "flags": {"ignore": true, "tool_managed": true}
        },
        {
          "name": "ISP_TILE1_INST0",
          "comment": "ISP Tile 1 Instance 0",
          "destinations": ["ISP1_CSR0", "ISP_TILE1_IBA_INST0", "ISP_TILE1_OBA_INST0", "ISP_TILE1_SLCR_GEN", "ISP_TILE1_SLCR_INST0"],
          "flags": {"ignore": true, "tool_managed": true}
        },
        {
          "name": "ISP_TILE1_dynamic",
          "comment": "ISP Tile 1 Dynamic",
          "destinations": ["ISP_TILE1_IBA_dynamic"],
          "flags": {"ignore": true, "tool_managed": true}
        },
        {
          "name": "ISP_TILE1_INST1",
          "comment": "ISP Tile 1 Instance 1",
          "destinations": ["ISP1_CSR1", "ISP_TILE1_IBA_INST1", "ISP_TILE1_OBA_INST1", "ISP_TILE1_SLCR_GEN"],
          "flags": {"ignore": true, "tool_managed": true}
        },
        {
          "name": "ISP_TILE2_INST0",
          "comment": "ISP Tile 2 Instance 0",
          "destinations": ["ISP2_CSR0", "ISP_TILE2_IBA_INST0", "ISP_TILE2_OBA_INST0", "ISP_TILE2_SLCR_GEN", "ISP_TILE2_SLCR_INST0"],
          "flags": {"ignore": true, "tool_managed": true}
        },
        {
          "name": "ISP_TILE2_dynamic",
          "comment": "ISP Tile 2 Dynamic",
          "destinations": ["ISP_TILE2_IBA_dynamic"],
          "flags": {"ignore": true, "tool_managed": true}
        },
        {
          "name": "ISP_TILE2_INST1",
          "comment": "ISP Tile 2 Instance 1",
          "destinations": ["ISP2_CSR1", "ISP_TILE2_IBA_INST1", "ISP_TILE2_OBA_INST1", "ISP_TILE2_SLCR_GEN"],
          "flags": {"ignore": true, "tool_managed": true}
        }
      ],
      "units": {
        "ASU": {
          "flags": {}
        },
        "ASU_XMPU": {
          "flags": {"enable": true}
        },
        "FPD_AFIFS_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "FPD_ASIL_B_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "FPD_ASIL_D_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "FPD_CMN_XMPU": {
          "root_access": "firmware",
          "flags": {"interrupt_enable": true, "lock": true}
        },
        "FPD_MMU_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "IPI": {
          "flags": {}
        },
        "IPI_PERM": {
          "flags": {}
        },
        "ISP0_XMPU": {
          "root_access": "firmware",
          "flags": {}
        },
        "ISP1_XMPU": {
          "root_access": "firmware",
          "flags": {}
        },
        "ISP2_XMPU": {
          "root_access": "firmware",
          "flags": {}
        },
        "LPD_AFIFS_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "LPD_EM": {
          "flags": {}
        },
        "LPD_SLCR_SECURE": {
          "flags": {}
        },
        "LPD_XPPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "MMI_XMPU": {
          "root_access": "firmware",
          "flags": {}
        },
        "OCM0_XMPU": {
          "root_access": "firmware_and_cci",
          "flags": {"interrupt_enable": true, "lock": true}
        },
        "OCM1_XMPU": {
          "root_access": "firmware_and_cci",
          "flags": {"interrupt_enable": true, "lock": true}
        },
        "OCM2_XMPU": {
          "root_access": "firmware_and_cci",
          "flags": {"interrupt_enable": true, "lock": true}
        },
        "OCM3_XMPU": {
          "root_access": "firmware_and_cci",
          "flags": {"interrupt_enable": true, "lock": true}
        },
        "OCM_TCM_XMPU": {
          "root_access": "firmware_and_cci",
          "flags": {}
        },
        "OCM_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "PLM": {
          "flags": {}
        },
        "PMC_EM": {
          "flags": {}
        },
        "PMC_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "PMC_XMPU_CFU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "PMC_XMPU_SBI": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "PMC_XPPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": false}
        },
        "PMC_XPPU_NPI": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "SECURE_REG_ACCESS": {
          "flags": {}
        },
        "SW_EM": {
          "flags": {}
        }
      }
    },
    "subsystems": {
      "default": {
        "id": "0x0",
        "access": [
          {
            "name": "cpus",
            "type": "cpu_list",
            "SMIDs": ["APU"]
          },
          {
            "name": "secure_cpus",
            "type": "cpu_list",
            "flags": {"secure": true},
            "SMIDs": ["RPU_A0", "RPU_B0"]
          },
          {
            "name": "uart",
            "destinations": ["UART0", "UART1"],
            "flags": {"requested": true, "requested_emit_wakeup": true, "requested_full_access": true, "requested_preserve_context": true, "shared": true}
          },
          {
            "name": "gem",
            "destinations": ["GEM0", "GEM1"],
            "flags": {"requested": true, "requested_emit_wakeup": true, "requested_full_access": true, "requested_preserve_context": true, "requested_secure": false, "secure": false, "shared": true}
          },
          {
            "name": "mem_ctrl",
            "destinations": ["DDR0"],
            "type": "ss_management",
            "flags": {"shared": true},
            "SMIDs": ["ANY"]
          },
          {
            "name": "mem",
            "destinations": ["OCM0_mem", "OCM1_mem", "OCM2_mem", "OCM3_mem"],
            "flags": {"requested": true, "requested_full_access": true, "requested_preserve_context": true, "shared": true},
            "SMIDs": ["ANY"]
          },
          {
            "name": "bootmedia",
            "destinations": ["EMMC", "OSPI", "QSPI", "SD"],
            "flags": {"requested": true, "requested_full_access": true, "requested_secure": false, "secure": false, "shared": true}
          },
          {
            "name": "OSPI_mem",
            "comment": "OSPI may require OSPI_mem",
            "destinations": ["OSPI_mem"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["APU"]
          },
          {
            "name": "misc_req_non_secure",
            "destinations": [
              "LPD_GPIO",
              "LPD_I3C0",
              "LPD_I3C1",
              "PMC_GPIO",
              "TTC0",
              "TTC1",
              "TTC2",
              "TTC3"
            ],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "ipi0",
            "destinations": ["IPI0"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["APU"]
          },
          {
            "name": "ipi1",
            "destinations": ["IPI1"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["RPU_A"]
          },
          {
            "name": "ipi2",
            "destinations": ["IPI2"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["RPU_B"]
          },
          {
            "name": "ipi5",
            "destinations": ["IPI5"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["DAP_and_DPC"]
          },
          {
            "name": "ipi_unused",
            "destinations": ["IPI3", "IPI4", "IPI6"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["UNUSED"]
          },
          {
            "name": "resets",
            "destinations": [
              "RST_NOC",
              "RST_NOC_POR",
              "RST_NPI",
              "RST_PL0",
              "RST_PL1",
              "RST_PL2",
              "RST_PL3",
              "RST_PL_POR",
              "RST_PL_SRST",
              "RST_PMC",
              "RST_PMC_POR",
              "RST_SYS_RST_1",
              "RST_SYS_RST_2",
              "RST_SYS_RST_3"
            ],
            "type": "ss_management"
          },
          {
            "name": "not_requested_mgr",
            "destinations": [
              "LPD_DMA0_CH0",
              "LPD_DMA0_CH1",
              "LPD_DMA0_CH2",
              "LPD_DMA0_CH3",
              "LPD_DMA0_CH4",
              "LPD_DMA0_CH5",
              "LPD_DMA0_CH6",
              "LPD_DMA0_CH7",
              "USB0_CSR",
              "USB1_CSR"
            ],
            "flags": {"shared": true}
          },
          {
            "name": "rpu_tcm",
            "destinations": [
              "RPU_A0_TCM_A",
              "RPU_A0_TCM_B",
              "RPU_A0_TCM_C",
              "RPU_A1_TCM_A",
              "RPU_A1_TCM_B",
              "RPU_A1_TCM_C",
              "RPU_B0_TCM_A",
              "RPU_B0_TCM_B",
              "RPU_B0_TCM_C",
              "RPU_B1_TCM_A",
              "RPU_B1_TCM_B",
              "RPU_B1_TCM_C"
            ],
            "flags": {"requested": true, "requested_full_access": true, "requested_preserve_context": true, "shared": true},
            "SMIDs": ["RPU_A", "RPU_B"]
          },
          {
            "name": "not_requested",
            "destinations": [
              "APU_A_SWDT",
              "APU_B_SWDT",
              "APU_C_SWDT",
              "APU_D_SWDT",
              "CANFD0",
              "CANFD1",
              "PMC_I3C",
              "PMC_RTC",
              "PMC_SYSMON",
              "SPI0",
              "SPI1"
            ],
            "flags": {"shared": true}
          }
        ]
      }
    }
  },
  "design": {
    "name": "design",
    "cells": {
      "NoC_C0_C1": {
        "type": "noc",
        "XMPUs": [
          {
            "name": "ddrmc",
            "module": "ddr5_xmpu",
            "config": {"dram_width": 16, "ip_has_gcm": false, "ip_has_ilc": false, "ip_has_xts": false, "memory_capacity": "4G", "num_ch": 1},
            "addrs": [
              {"addr": "0x0", "size": "2G"},
              {"addr": "0x800000000", "size": "32G"}
            ],
            "sites": ["DDRMC5E_X0Y0", "DDRMC5E_X1Y0"]
          }
        ],
        "destinations": [
          {"name": "DDR_CH0_LEGACY", "addr": "0x0", "size": "2G", "mem": true},
          {"name": "DDR_CH0_MED", "addr": "0x800000000", "size": "2G", "mem": true}
        ]
      },
      "NoC_C2_C3": {
        "type": "noc",
        "XMPUs": [
          {
            "name": "ddrmc",
            "module": "ddr5_xmpu",
            "config": {"dram_width": 16, "ip_has_gcm": false, "ip_has_ilc": false, "ip_has_xts": false, "memory_capacity": "4G", "num_ch": 1},
            "addrs": [
              {"addr": "0x50000000000", "size": "512G"}
            ],
            "sites": ["DDRMC5E_X2Y0", "DDRMC5E_X3Y0"]
          }
        ],
        "destinations": [
          {"name": "DDR_CH1", "addr": "0x50000000000", "size": "4G", "mem": true}
        ]
      },
      "NoC_C4": {
        "type": "noc",
        "XMPUs": [
          {
            "name": "ddrmc",
            "module": "ddr5_xmpu",
            "config": {"dram_width": 16, "ip_has_gcm": false, "ip_has_ilc": false, "ip_has_xts": false, "memory_capacity": "2G", "num_ch": 1},
            "addrs": [
              {"addr": "0x60000000000", "size": "512G"}
            ],
            "sites": ["DDRMC5E_X4Y0"]
          }
        ],
        "destinations": [
          {"name": "DDR_CH2", "addr": "0x60000000000", "size": "2G", "mem": true}
        ]
      },
      "isp": {
        "type": "ip",
        "vlnv": "xilinx.com:ip:visp_ss",
        "SMIDs": [
          {"name": "ISP", "comment": "Image Signal Processor", "value": "0xe0", "count": 16},
          {"name": "ISP_TILE0", "comment": "Image Signal Processor Tile 0", "value": "0xe0", "count": 4},
          {"name": "ISP_TILE0_INST0", "comment": "Image Signal Processor Tile 0 instance 0 DMA", "value": "0xe0"},
          {"name": "ISP_stats", "comment": "Image Signal Processor stats DMAs", "value": "0xe1", "mask_n": "0xe"},
          {"name": "ISP_TILE0_INST0_stats", "comment": "Image Signal Processor Tile 0 instance 0 stats DMA", "value": "0xe1"},
          {"name": "ISP_TILE0_INST1", "comment": "Image Signal Processor Tile 0 instance 1 DMA", "value": "0xe2"},
          {"name": "ISP_TILE0_INST1_stats", "comment": "Image Signal Processor Tile 0 instance 1 stats DMA", "value": "0xe3"},
          {"name": "ISP_TILE1", "comment": "Image Signal Processor Tile 1", "value": "0xe4", "count": 4},
          {"name": "ISP_TILE1_INST0", "comment": "Image Signal Processor Tile 1 instance 0 DMA", "value": "0xe4"},
          {"name": "ISP_TILE1_INST0_stats", "comment": "Image Signal Processor Tile 1 instance 0 stats DMA", "value": "0xe5"},
          {"name": "ISP_TILE1_INST1", "comment": "Image Signal Processor Tile 1 instance 1 DMA", "value": "0xe6"},
          {"name": "ISP_TILE1_INST1_stats", "comment": "Image Signal Processor Tile 1 instance 1 stats DMA", "value": "0xe7"},
          {"name": "ISP_TILE2", "comment": "Image Signal Processor Tile 2", "value": "0xe8", "count": 4},
          {"name": "ISP_TILE2_INST0", "comment": "Image Signal Processor Tile 2 instance 0 DMA", "value": "0xe8"},
          {"name": "ISP_TILE2_INST0_stats", "comment": "Image Signal Processor Tile 2 instance 0 stats DMA", "value": "0xe9"},
          {"name": "ISP_TILE2_INST1", "comment": "Image Signal Processor Tile 2 instance 1 DMA", "value": "0xea"},
          {"name": "ISP_TILE2_INST1_stats", "comment": "Image Signal Processor Tile 2 instance 1 stats DMA", "value": "0xeb"}
        ],
        "destinations": []
      },
      "ps": {
        "type": "ps",
        "SMIDs": [
          {"name": "ANY", "comment": "Matches all SMIDs", "value": "0x0", "count": 1024},
          {"name": "PL_AIE_CPM", "value": "0x0", "count": 512},
          {"name": "FPD_CCI", "comment": "Issued by CCI-500 cache management", "value": "0x0"},
          {"name": "PS", "value": "0x200", "count": 128, "altname": "PSX"},
          {"name": "LPD", "value": "0x200", "count": 64},
          {"name": "RPU_A", "value": "0x200", "count": 2, "cpu": true, "type": "rpu"},
          {"name": "RPU_A0", "value": "0x200", "count": 1, "cpu": true, "type": "rpu", "nodeid": "0x181100bf", "constants": {"index": 0, "override": true}},
          {"name": "RPU_A1", "value": "0x201", "count": 1, "cpu": true, "type": "rpu", "nodeid": "0x181100c0", "constants": {"index": 1, "override": true}},
          {"name": "RPU_B", "value": "0x202", "count": 2, "cpu": true, "type": "rpu"},
          {"name": "RPU_B0", "value": "0x202", "count": 1, "cpu": true, "type": "rpu", "nodeid": "0x181100c1", "constants": {"index": 2, "override": true}},
          {"name": "RPU_B1", "value": "0x203", "count": 1, "cpu": true, "type": "rpu", "nodeid": "0x181100c2", "constants": {"index": 3, "override": true}},
          {"name": "RPU_C", "value": "0x204", "count": 2, "cpu": true, "type": "rpu"},
          {"name": "RPU_C0", "value": "0x204", "count": 1, "cpu": true, "type": "rpu", "nodeid": "0x181100f1", "constants": {"index": 4, "override": true}},
          {"name": "RPU_C1", "value": "0x205", "count": 1, "cpu": true, "type": "rpu", "nodeid": "0x181100f2", "constants": {"index": 5, "override": true}},
          {"name": "RPU_D", "value": "0x206", "count": 2, "cpu": true, "type": "rpu"},
          {"name": "RPU_D0", "value": "0x206", "count": 1, "cpu": true, "type": "rpu", "nodeid": "0x181100f3", "constants": {"index": 6, "override": true}},
          {"name": "RPU_D1", "value": "0x207", "count": 1, "cpu": true, "type": "rpu", "nodeid": "0x181100f4", "constants": {"index": 7, "override": true}},
          {"name": "RPU_E", "value": "0x208", "count": 2, "cpu": true, "type": "rpu"},
          {"name": "RPU_E0", "value": "0x208", "count": 1, "cpu": true, "type": "rpu", "nodeid": "0x181100f5", "constants": {"index": 8, "override": true}},
          {"name": "RPU_E1", "value": "0x209", "count": 1, "cpu": true, "type": "rpu", "nodeid": "0x181100f6", "constants": {"index": 9, "override": true}},
          {"name": "MMI_GPU6", "value": "0x20c", "count": 1, "constants": {"always_override": true, "override": true}},
          {"name": "MMI_USB", "value": "0x20e", "count": 1, "constants": {"override": true}},
          {"name": "MMI_DISPLAY_CONTROLLER", "value": "0x20f", "count": 1, "constants": {"override": true}},
          {"name": "LPD_DMA0_CH", "value": "0x210", "count": 16},
          {"name": "LPD_DMA0_CH0", "value": "0x210", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA0_CH1", "value": "0x212", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA0_CH2", "value": "0x214", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA0_CH3", "value": "0x216", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA0_CH4", "value": "0x218", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA0_CH5", "value": "0x21a", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA0_CH6", "value": "0x21c", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA0_CH7", "value": "0x21e", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA1_CH", "value": "0x220", "count": 16},
          {"name": "LPD_DMA1_CH0", "value": "0x220", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA1_CH1", "value": "0x222", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA1_CH2", "value": "0x224", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA1_CH3", "value": "0x226", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA1_CH4", "value": "0x228", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA1_CH5", "value": "0x22a", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA1_CH6", "value": "0x22c", "count": 2, "constants": {"override": true}},
          {"name": "LPD_DMA1_CH7", "value": "0x22e", "count": 2, "constants": {"override": true}},
          {"name": "USB", "value": "0x230", "count": 2, "altname": "USB2"},
          {"name": "USB0", "value": "0x230", "count": 1, "constants": {"override": true}},
          {"name": "USB1", "value": "0x231", "count": 1, "constants": {"override": true}},
          {"name": "GEM", "value": "0x234", "count": 4},
          {"name": "GEM0", "value": "0x234", "count": 1, "constants": {"override": true}},
          {"name": "GEM1", "value": "0x235", "count": 1, "constants": {"override": true}},
          {"name": "GEM2", "value": "0x236", "count": 1},
          {"name": "GEM3", "value": "0x237", "count": 1},
          {"name": "HSDP_DMA", "value": "0x23d", "count": 1, "altname": "DPC_DMA", "constants": {"override": true}},
          {"name": "APU_GIC", "value": "0x23e", "count": 1, "constants": {"override": true}},
          {"name": "MMI_HSDP", "value": "0x23f", "count": 1},
          {"name": "PMC", "value": "0x240", "count": 16},
          {"name": "DAP_and_DPC", "comment": "used for IPI ", "value": "0x240", "count": 2},
          {"name": "DAP", "comment": "JTAG Debug Access Port", "value": "0x240", "count": 1, "constants": {"override": true}},
          {"name": "HSDP", "comment": "Debug Port Controller", "value": "0x241", "count": 1, "constants": {"override": true}},
          {"name": "SD", "comment": "SD v4.51 Controller", "value": "0x242", "count": 1, "altname": "SD_eMMC", "constants": {"override": true}},
          {"name": "eMMC", "comment": "eMMC v5.1 Controller", "value": "0x243", "count": 1, "constants": {"override": true}},
          {"name": "QSPI", "comment": "QSPI Controller", "value": "0x244", "count": 1, "constants": {"override": true}},
          {"name": "OSPI", "comment": "OSPI Controller", "value": "0x245", "count": 1, "constants": {"override": true}},
          {"name": "UFS", "value": "0x246", "count": 1, "constants": {"override": true}},
          {"name": "RCU_and_PPU", "value": "0x248", "count": 2},
          {"name": "RCU", "comment": "ROM Code Unit", "value": "0x248", "count": 1, "cpu": true},
          {"name": "PPU", "value": "0x249", "count": 1},
          {"name": "PMC_DMA", "value": "0x24a", "count": 2},
          {"name": "PMC_DMA0", "value": "0x24a", "count": 1, "constants": {"override": true}},
          {"name": "PMC_DMA1", "value": "0x24b", "count": 1, "constants": {"override": true}},
          {"name": "ASU", "value": "0x24c", "count": 4},
          {"name": "ASU_RISC_V", "value": "0x24c", "count": 1, "constants": {"override": true}},
          {"name": "ASU_DMA0", "value": "0x24d", "count": 1, "constants": {"override": true}},
          {"name": "ASU_DMA1", "value": "0x24e", "count": 1, "constants": {"override": true}},
          {"name": "MMI_PCIE", "value": "0x250", "count": 2},
          {"name": "MMI_PCIE0", "value": "0x250", "count": 1, "constants": {"override": true}},
          {"name": "MMI_PCIE1", "value": "0x251", "count": 1, "constants": {"override": true}},
          {"name": "MMI_GPU0_4", "value": "0x254", "count": 4},
          {"name": "MMI_GPU0", "value": "0x254", "count": 1, "constants": {"override": true}},
          {"name": "MMI_GPU1", "value": "0x255", "count": 1, "constants": {"override": true}},
          {"name": "MMI_GPU2", "value": "0x256", "count": 1, "constants": {"override": true}},
          {"name": "MMI_GPU3", "value": "0x257", "count": 1, "constants": {"override": true}},
          {"name": "MMI_GPU4", "value": "0x258", "count": 1, "constants": {"override": true}},
          {"name": "DEBUG", "comment": "CoreSight", "value": "0x259", "count": 1},
          {"name": "MMI_TCU", "value": "0x25a", "count": 1, "constants": {"override": true}},
          {"name": "MMI_GPU7", "value": "0x25b", "count": 1, "constants": {"override": true}},
          {"name": "MMI_GPU8_9", "value": "0x25c", "count": 2},
          {"name": "MMI_GPU8", "value": "0x25c", "count": 1, "constants": {"override": true}},
          {"name": "MMI_GPU9", "value": "0x25d", "count": 1, "constants": {"override": true}},
          {"name": "MMI_GEM", "value": "0x25e", "count": 1, "constants": {"override": true}},
          {"name": "MMI_GPU5", "value": "0x25f", "count": 1, "constants": {"always_override": true, "override": true}},
          {"name": "APU", "value": "0x260", "count": 32, "cpu": true, "type": "apu"},
          {"name": "APU_A_ALL", "value": "0x260", "count": 8},
          {"name": "APU_A", "value": "0x260", "count": 2, "cpu": true, "type": "apu"},
          {"name": "APU_A0", "value": "0x260", "count": 1, "cpu": true, "type": "apu", "nodeid": "0x1810c0af"},
          {"name": "APU_A1", "value": "0x261", "count": 1, "cpu": true, "type": "apu", "nodeid": "0x1810c0b0"},
          {"name": "APU_A_APC", "value": "0x264", "count": 1},
          {"name": "APU_A_noncpu", "value": "0x265", "count": 1},
          {"name": "APU_B_ALL", "value": "0x268", "count": 8},
          {"name": "APU_B", "value": "0x268", "count": 2, "cpu": true, "type": "apu"},
          {"name": "APU_B0", "value": "0x268", "count": 1, "cpu": true, "type": "apu", "nodeid": "0x1810c0b3"},
          {"name": "APU_B1", "value": "0x269", "count": 1, "cpu": true, "type": "apu", "nodeid": "0x1810c0b4"},
          {"name": "APU_B_APC", "value": "0x26c", "count": 1},
          {"name": "APU_B_noncpu", "value": "0x26d", "count": 1},
          {"name": "APU_C_ALL", "value": "0x270", "count": 8},
          {"name": "APU_C", "value": "0x270", "count": 2, "cpu": true, "type": "apu"},
          {"name": "APU_C0", "value": "0x270", "count": 1, "cpu": true, "type": "apu", "nodeid": "0x1810c0b7"},
          {"name": "APU_C1", "value": "0x271", "count": 1, "cpu": true, "type": "apu", "nodeid": "0x1810c0b8"},
          {"name": "APU_C_APC", "value": "0x274", "count": 1},
          {"name": "APU_C_noncpu", "value": "0x275", "count": 1},
          {"name": "APU_D_ALL", "value": "0x278", "count": 8},
          {"name": "APU_D", "value": "0x278", "count": 2, "cpu": true, "type": "apu"},
          {"name": "APU_D0", "value": "0x278", "count": 1, "cpu": true, "type": "apu", "nodeid": "0x1810c0bb"},
          {"name": "APU_D1", "value": "0x279", "count": 1, "cpu": true, "type": "apu", "nodeid": "0x1810c0bc"},
          {"name": "APU_D_APC", "value": "0x27c", "count": 1},
          {"name": "APU_D_noncpu", "value": "0x27d", "count": 1},
          {"name": "UNUSED", "comment": "Unused SMID used for IPI channels", "value": "0x3ff", "altname": "NONE"}
        ],
        "destinations": [
          {"name": "DDR0", "addr": "0x0", "size": "0", "nodeid": "0x18320010"},
          {"name": "GGS0", "addr": "0x0", "size": "0", "nodeid": "0x18248000"},
          {"name": "GGS1", "addr": "0x0", "size": "0", "nodeid": "0x18248001"},
          {"name": "GGS2", "addr": "0x0", "size": "0", "nodeid": "0x18248002"},
          {"name": "GGS3", "addr": "0x0", "size": "0", "nodeid": "0x18248003"},
          {"name": "HB_MON0", "addr": "0x0", "size": "0", "nodeid": "0x18250000"},
          {"name": "HB_MON1", "addr": "0x0", "size": "0", "nodeid": "0x18250001"},
          {"name": "HB_MON2", "addr": "0x0", "size": "0", "nodeid": "0x18250002"},
          {"name": "HB_MON3", "addr": "0x0", "size": "0", "nodeid": "0x18250003"},
          {"name": "HB_MON4", "addr": "0x0", "size": "0", "nodeid": "0x18250004"},
          {"name": "HB_MON5", "addr": "0x0", "size": "0", "nodeid": "0x18250005"},
          {"name": "HB_MON6", "addr": "0x0", "size": "0", "nodeid": "0x18250006"},
          {"name": "HB_MON7", "addr": "0x0", "size": "0", "nodeid": "0x18250007"},
          {"name": "PGGS0", "addr": "0x0", "size": "0", "nodeid": "0x1824c004"},
          {"name": "PGGS1", "addr": "0x0", "size": "0", "nodeid": "0x1824c005"},
          {"name": "RST_NOC", "addr": "0x0", "size": "0", "nodeid": "0xc41000c"},
          {"name": "RST_NOC_POR", "addr": "0x0", "size": "0", "nodeid": "0xc30c005"},
          {"name": "RST_NPI", "addr": "0x0", "size": "0", "nodeid": "0xc41000d"},
          {"name": "RST_PL0", "addr": "0x0", "size": "0", "nodeid": "0xc410012"},
          {"name": "RST_PL1", "addr": "0x0", "size": "0", "nodeid": "0xc410013"},
          {"name": "RST_PL2", "addr": "0x0", "size": "0", "nodeid": "0xc410014"},
          {"name": "RST_PL3", "addr": "0x0", "size": "0", "nodeid": "0xc410015"},
          {"name": "RST_PL_POR", "addr": "0x0", "size": "0", "nodeid": "0xc30c004"},
          {"name": "RST_PL_SRST", "addr": "0x0", "size": "0", "nodeid": "0xc41000b"},
          {"name": "RST_PMC", "addr": "0x0", "size": "0", "nodeid": "0xc410002"},
          {"name": "RST_PMC_POR", "addr": "0x0", "size": "0", "nodeid": "0xc30c001"},
          {"name": "RST_SYS_RST_1", "addr": "0x0", "size": "0", "nodeid": "0xc41000e"},
          {"name": "RST_SYS_RST_2", "addr": "0x0", "size": "0", "nodeid": "0xc41000f"},
          {"name": "RST_SYS_RST_3", "addr": "0x0", "size": "0", "nodeid": "0xc410010"},
          {"name": "OCM2_0_mem", "addr": "0xbbe00000", "size": "128K", "mem": true, "nodeid": "0x183140f8"},
          {"name": "OCM2_1_mem", "addr": "0xbbe20000", "size": "128K", "mem": true, "nodeid": "0x183140f9"},
          {"name": "OCM2_2_mem", "addr": "0xbbe40000", "size": "128K", "mem": true, "nodeid": "0x183140fa"},
          {"name": "OCM2_3_mem", "addr": "0xbbe60000", "size": "128K", "mem": true, "nodeid": "0x183140fb"},
          {"name": "OCM3_0_mem", "addr": "0xbbe80000", "size": "128K", "mem": true, "nodeid": "0x183140fc"},
          {"name": "OCM3_1_mem", "addr": "0xbbea0000", "size": "128K", "mem": true, "nodeid": "0x183140fd"},
          {"name": "OCM3_2_mem", "addr": "0xbbec0000", "size": "128K", "mem": true, "nodeid": "0x183140fe"},
          {"name": "OCM3_3_mem", "addr": "0xbbee0000", "size": "128K", "mem": true, "nodeid": "0x183140ff"},
          {"name": "OCM0_0_mem", "addr": "0xbbf00000", "size": "128K", "mem": true, "nodeid": "0x183140c3"},
          {"name": "OCM0_1_mem", "addr": "0xbbf20000", "size": "128K", "mem": true, "nodeid": "0x183140c4"},
          {"name": "OCM0_2_mem", "addr": "0xbbf40000", "size": "128K", "mem": true, "nodeid": "0x183140c5"},
          {"name": "OCM0_3_mem", "addr": "0xbbf60000", "size": "128K", "mem": true, "nodeid": "0x183140c6"},
          {"name": "OCM1_0_mem", "addr": "0xbbf80000", "size": "128K", "mem": true, "nodeid": "0x183140c7"},
          {"name": "OCM1_1_mem", "addr": "0xbbfa0000", "size": "128K", "mem": true, "nodeid": "0x183140c8"},
          {"name": "OCM1_2_mem", "addr": "0xbbfc0000", "size": "128K", "mem": true, "nodeid": "0x183140c9"},
          {"name": "OCM1_3_mem", "addr": "0xbbfe0000", "size": "128K", "mem": true, "nodeid": "0x183140ca"},
          {"name": "LPD_XPPU_64KB_apertures", "addr": "0xeb000000", "size": "16M", "nodeid": "0x182240d9"},
          {"name": "LPD_WWDT0", "addr": "0xeb000000", "size": "64K", "nodeid": "0x182240d9"},
          {"name": "LPD_WWDT1", "addr": "0xeb010000", "size": "64K", "nodeid": "0x182240da"},
          {"name": "LPD_WWDT2", "addr": "0xeb020000", "size": "64K", "nodeid": "0x18224112"},
          {"name": "LPD_WWDT3", "addr": "0xeb030000", "size": "64K", "nodeid": "0x18224113"},
          {"name": "LPD_WWDT4", "addr": "0xeb040000", "size": "64K", "nodeid": "0x18224114"},
          {"name": "IPI_channels", "addr": "0xeb310000", "size": "704K", "nodeid": "0x18224115"},
          {"name": "IPI_ASU", "addr": "0xeb310000", "size": "64K", "nodeid": "0x18224115", "constants": {"index": 0}},
          {"name": "IPI0", "addr": "0xeb330000", "size": "64K", "nodeid": "0x1822403d", "constants": {"index": 2}},
          {"name": "IPI1", "addr": "0xeb340000", "size": "64K", "nodeid": "0x1822403e", "constants": {"index": 3}},
          {"name": "IPI2", "addr": "0xeb350000", "size": "64K", "nodeid": "0x1822403f", "constants": {"index": 4}},
          {"name": "IPI3", "addr": "0xeb360000", "size": "64K", "nodeid": "0x18224040", "constants": {"index": 5}},
          {"name": "IPI4", "addr": "0xeb370000", "size": "64K", "nodeid": "0x18224041", "constants": {"index": 6}},
          {"name": "IPI5", "addr": "0xeb380000", "size": "64K", "nodeid": "0x18224042", "constants": {"index": 7}},
          {"name": "IPI6", "addr": "0xeb3a0000", "size": "4K", "nodeid": "0x18224043", "constants": {"index": 9}},
          {"name": "IPI_NOBUF1", "addr": "0xeb3b0000", "size": "4K", "nodeid": "0x182240e3", "constants": {"index": 10}},
          {"name": "IPI_NOBUF2", "addr": "0xeb3b1000", "size": "4K", "nodeid": "0x182240e4", "constants": {"index": 11}},
          {"name": "IPI_NOBUF3", "addr": "0xeb3b2000", "size": "4K", "nodeid": "0x182240e5", "constants": {"index": 12}},
          {"name": "IPI_NOBUF4", "addr": "0xeb3b3000", "size": "4K", "nodeid": "0x182240e6", "constants": {"index": 13}},
          {"name": "IPI_NOBUF5", "addr": "0xeb3b4000", "size": "4K", "nodeid": "0x182240e7", "constants": {"index": 14}},
          {"name": "IPI_NOBUF6", "addr": "0xeb3b5000", "size": "4K", "nodeid": "0x182240e8", "constants": {"index": 15}},
          {"name": "RPU_A0_TCM_A", "addr": "0xeba00000", "size": "64K", "mem": true, "nodeid": "0x183180cb"},
          {"name": "RPU_A0_TCM_B", "addr": "0xeba10000", "size": "32K", "mem": true, "nodeid": "0x183180cc"},
          {"name": "RPU_A0_TCM_C", "addr": "0xeba20000", "size": "32K", "mem": true, "nodeid": "0x183180cd"},
          {"name": "RPU_A1_TCM_A", "addr": "0xeba40000", "size": "64K", "mem": true, "nodeid": "0x183180ce"},
          {"name": "RPU_A1_TCM_B", "addr": "0xeba50000", "size": "32K", "mem": true, "nodeid": "0x183180cf"},
          {"name": "RPU_A1_TCM_C", "addr": "0xeba60000", "size": "32K", "mem": true, "nodeid": "0x183180d0"},
          {"name": "RPU_B0_TCM_A", "addr": "0xeba80000", "size": "64K", "mem": true, "nodeid": "0x183180d1"},
          {"name": "RPU_B0_TCM_B", "addr": "0xeba90000", "size": "32K", "mem": true, "nodeid": "0x183180d2"},
          {"name": "RPU_B0_TCM_C", "addr": "0xebaa0000", "size": "32K", "mem": true, "nodeid": "0x183180d3"},
          {"name": "RPU_B1_TCM_A", "addr": "0xebac0000", "size": "64K", "mem": true, "nodeid": "0x183180d4"},
          {"name": "RPU_B1_TCM_B", "addr": "0xebad0000", "size": "32K", "mem": true, "nodeid": "0x183180d5"},
          {"name": "RPU_B1_TCM_C", "addr": "0xebae0000", "size": "32K", "mem": true, "nodeid": "0x183180d6"},
          {"name": "RPU_C0_TCM_A", "addr": "0xebb00000", "size": "64K", "mem": true, "nodeid": "0x18318100"},
          {"name": "RPU_C0_TCM_B", "addr": "0xebb10000", "size": "32K", "mem": true, "nodeid": "0x18318101"},
          {"name": "RPU_C0_TCM_C", "addr": "0xebb20000", "size": "32K", "mem": true, "nodeid": "0x18318102"},
          {"name": "RPU_C1_TCM_A", "addr": "0xebb40000", "size": "64K", "mem": true, "nodeid": "0x18318103"},
          {"name": "RPU_C1_TCM_B", "addr": "0xebb50000", "size": "32K", "mem": true, "nodeid": "0x18318104"},
          {"name": "RPU_C1_TCM_C", "addr": "0xebb60000", "size": "32K", "mem": true, "nodeid": "0x18318105"},
          {"name": "RPU_D0_TCM_A", "addr": "0xebb80000", "size": "64K", "mem": true, "nodeid": "0x18318106"},
          {"name": "RPU_D0_TCM_B", "addr": "0xebb90000", "size": "32K", "mem": true, "nodeid": "0x18318107"},
          {"name": "RPU_D0_TCM_C", "addr": "0xebba0000", "size": "32K", "mem": true, "nodeid": "0x18318108"},
          {"name": "RPU_D1_TCM_A", "addr": "0xebbc0000", "size": "64K", "mem": true, "nodeid": "0x18318109"},
          {"name": "RPU_D1_TCM_B", "addr": "0xebbd0000", "size": "32K", "mem": true, "nodeid": "0x1831810a"},
          {"name": "RPU_D1_TCM_C", "addr": "0xebbe0000", "size": "32K", "mem": true, "nodeid": "0x1831810b"},
          {"name": "RPU_E0_TCM_A", "addr": "0xebc00000", "size": "64K", "mem": true, "nodeid": "0x1831810c"},
          {"name": "RPU_E0_TCM_B", "addr": "0xebc10000", "size": "32K", "mem": true, "nodeid": "0x1831810d"},
          {"name": "RPU_E0_TCM_C", "addr": "0xebc20000", "size": "32K", "mem": true, "nodeid": "0x1831810e"},
          {"name": "RPU_E1_TCM_A", "addr": "0xebc40000", "size": "64K", "mem": true, "nodeid": "0x1831810f"},
          {"name": "RPU_E1_TCM_B", "addr": "0xebc50000", "size": "32K", "mem": true, "nodeid": "0x18318110"},
          {"name": "RPU_E1_TCM_C", "addr": "0xebc60000", "size": "32K", "mem": true, "nodeid": "0x18318111"},
          {"name": "LPD_DMA0_CH0", "addr": "0xebd00000", "size": "64K", "nodeid": "0x18224035"},
          {"name": "LPD_DMA0_CH1", "addr": "0xebd10000", "size": "64K", "nodeid": "0x18224036"},
          {"name": "LPD_DMA0_CH2", "addr": "0xebd20000", "size": "64K", "nodeid": "0x18224037"},
          {"name": "LPD_DMA0_CH3", "addr": "0xebd30000", "size": "64K", "nodeid": "0x18224038"},
          {"name": "LPD_DMA0_CH4", "addr": "0xebd40000", "size": "64K", "nodeid": "0x18224039"},
          {"name": "LPD_DMA0_CH5", "addr": "0xebd50000", "size": "64K", "nodeid": "0x1822403a"},
          {"name": "LPD_DMA0_CH6", "addr": "0xebd60000", "size": "64K", "nodeid": "0x1822403b"},
          {"name": "LPD_DMA0_CH7", "addr": "0xebd70000", "size": "64K", "nodeid": "0x1822403c"},
          {"name": "ASU", "addr": "0xebe00000", "size": "2M", "nodeid": "0x181600f7"},
          {"name": "ASU_GLOBAL", "addr": "0xebf80000", "size": "128K", "nodeid": "0x181600f7"},
          {"name": "APU_A_SWDT", "addr": "0xecc10000", "size": "64K", "nodeid": "0x182240db"},
          {"name": "APU_B_SWDT", "addr": "0xecd10000", "size": "64K", "nodeid": "0x182240dc"},
          {"name": "APU_C_SWDT", "addr": "0xece10000", "size": "64K", "nodeid": "0x182240dd"},
          {"name": "APU_D_SWDT", "addr": "0xecf10000", "size": "64K", "nodeid": "0x182240de"},
          {"name": "MMI_GPU_SLCR", "addr": "0xed720000", "size": "8K", "nodeid": "0x18224136"},
          {"name": "MMI_PCIEGEM_10GBE", "addr": "0xed920000", "size": "64K", "nodeid": "0x1822413a"},
          {"name": "MMI_DP", "addr": "0xedd00000", "size": "32K", "nodeid": "0x18224139"},
          {"name": "MMI_DC", "addr": "0xedd08000", "size": "32K", "nodeid": "0x18224137"},
          {"name": "MMI_UDH_HDCP", "addr": "0xedeb0000", "size": "32K", "nodeid": "0x18224138"},
          {"name": "MMI_USB_CFG", "addr": "0xedec0000", "size": "64K", "nodeid": "0x18224135"},
          {"name": "PMC_SWDT", "addr": "0xf03f0000", "size": "64K", "nodeid": "0x182240d8"},
          {"name": "PMC_I3C", "addr": "0xf1000000", "size": "64K", "nodeid": "0x1822402d"},
          {"name": "OSPI", "addr": "0xf1010000", "size": "64K", "nodeid": "0x1822402a"},
          {"name": "PMC_GPIO", "addr": "0xf1020000", "size": "64K", "nodeid": "0x1822402c"},
          {"name": "QSPI", "addr": "0xf1030000", "size": "64K", "nodeid": "0x1822402b"},
          {"name": "SD", "addr": "0xf1040000", "size": "64K", "nodeid": "0x1822402e"},
          {"name": "EMMC", "addr": "0xf1050000", "size": "64K", "nodeid": "0x1822402f"},
          {"name": "UFS_XHCI", "addr": "0xf10b0000", "size": "64K", "nodeid": "0x18224116"},
          {"name": "PMC_EFUSE_CACHE", "addr": "0xf1250000", "size": "64K", "nodeid": "0x18330054"},
          {"name": "PMC_SYSMON", "addr": "0xf1270000", "size": "192K", "nodeid": "0x18224055"},
          {"name": "PMC_RTC", "addr": "0xf12a0000", "size": "64K", "nodeid": "0x18224034"},
          {"name": "UART0", "addr": "0xf1920000", "size": "64K", "nodeid": "0x18224021"},
          {"name": "UART1", "addr": "0xf1930000", "size": "64K", "nodeid": "0x18224022"},
          {"name": "LPD_I3C0", "addr": "0xf1940000", "size": "64K", "nodeid": "0x1822401d"},
          {"name": "LPD_I3C1", "addr": "0xf1950000", "size": "64K", "nodeid": "0x1822401e"},
          {"name": "LPD_I3C2", "addr": "0xf1960000", "size": "64K", "nodeid": "0x18224117"},
          {"name": "LPD_I3C3", "addr": "0xf1970000", "size": "64K", "nodeid": "0x18224118"},
          {"name": "LPD_I3C4", "addr": "0xf1980000", "size": "64K", "nodeid": "0x18224119"},
          {"name": "LPD_I3C5", "addr": "0xf1990000", "size": "64K", "nodeid": "0x1822411a"},
          {"name": "LPD_I3C6", "addr": "0xf19a0000", "size": "64K", "nodeid": "0x1822411b"},
          {"name": "LPD_I3C7", "addr": "0xf19b0000", "size": "64K", "nodeid": "0x1822411c"},
          {"name": "SPI0", "addr": "0xf19c0000", "size": "64K", "nodeid": "0x1822401b"},
          {"name": "SPI1", "addr": "0xf19d0000", "size": "64K", "nodeid": "0x1822401c"},
          {"name": "CANFD0", "addr": "0xf19e0000", "size": "64K", "nodeid": "0x1822401f"},
          {"name": "CANFD1", "addr": "0xf19f0000", "size": "64K", "nodeid": "0x18224020"},
          {"name": "CANFD2", "addr": "0xf1a00000", "size": "64K", "nodeid": "0x1822411d"},
          {"name": "CANFD3", "addr": "0xf1a10000", "size": "64K", "nodeid": "0x1822411e"},
          {"name": "LPD_GPIO", "addr": "0xf1a50000", "size": "64K", "nodeid": "0x18224023"},
          {"name": "GEM0", "addr": "0xf1a60000", "size": "64K", "nodeid": "0x18224019"},
          {"name": "GEM1", "addr": "0xf1a70000", "size": "64K", "nodeid": "0x1822401a"},
          {"name": "TTC0", "addr": "0xf1e60000", "size": "64K", "nodeid": "0x18224024"},
          {"name": "TTC1", "addr": "0xf1e70000", "size": "64K", "nodeid": "0x18224025"},
          {"name": "TTC2", "addr": "0xf1e80000", "size": "64K", "nodeid": "0x18224026"},
          {"name": "TTC3", "addr": "0xf1e90000", "size": "64K", "nodeid": "0x18224027"},
          {"name": "TTC4", "addr": "0xf1ea0000", "size": "64K", "nodeid": "0x1822411f"},
          {"name": "TTC5", "addr": "0xf1eb0000", "size": "64K", "nodeid": "0x18224120"},
          {"name": "TTC6", "addr": "0xf1ec0000", "size": "64K", "nodeid": "0x18224121"},
          {"name": "TTC7", "addr": "0xf1ed0000", "size": "64K", "nodeid": "0x18224122"},
          {"name": "USB0_CSR", "addr": "0xf1ee0000", "size": "64K", "nodeid": "0x18224018"},
          {"name": "USB1_CSR", "addr": "0xf1ef0000", "size": "64K", "nodeid": "0x182240d7"}
        ]
      },
      "vcu": {
        "type": "ip",
        "vlnv": "xilinx.com:ip:vcu",
        "SMIDs": [
          {"name": "VCU", "comment": "VCU", "value": "0xd8", "count": 8},
          {"name": "VCU_DEC", "comment": "VCU AXI Decoder", "value": "0xd8", "count": 4},
          {"name": "VCU_DEC_AXI_ARUSER", "comment": "AXI Decoder ARUSER SMID Value", "value": "0xd8"},
          {"name": "VCU_DEC_AXI_AWUSER", "comment": "AXI Decoder AWUSER SMID Value", "value": "0xd9"},
          {"name": "VCU_DEC_MCU_AXI_ARUSER", "comment": "AXI Decoder MCU ARUSER SMID Value", "value": "0xda"},
          {"name": "VCU_DEC_MCU_AXI_AWUSER", "comment": "AXI Decoder MCU AWUSER SMID Value", "value": "0xdb"},
          {"name": "VCU_ENC", "comment": "VCU AXI Encoder", "value": "0xdc", "count": 4},
          {"name": "VCU_ENC_AXI_ARUSER", "comment": "AXI Encoder ARUSER SMID Value", "value": "0xdc"},
          {"name": "VCU_ENC_AXI_AWUSER", "comment": "AXI Encoder AWUSER SMID Value", "value": "0xdd"},
          {"name": "VCU_ENC_MCU_AXI_ARUSER", "comment": "AXI Encoder MCU ARUSER SMID Value", "value": "0xde"},
          {"name": "VCU_ENC_MCU_AXI_AWUSER", "comment": "AXI Encoder MCU AWUSER SMID Value", "value": "0xdf"}
        ],
        "destinations": []
      }
    },
    "base_protection": {
      "access": [
        {"same_as_default": "firmware_and_cci"},
        {"same_as_default": "firmware_and_cci.debug"},
        {"same_as_default": "firmware"},
        {"same_as_default": "firmware.debug"},
        {"same_as_default": "apu_gic_dist"},
        {"same_as_default": "apu_gic_redist_apu_rw"},
        {"same_as_default": "open_rw"},
        {"same_as_default": "open_rw_2"},
        {"same_as_default": "open_ro"},
        {"same_as_default": "apu_rw_temp"},
        {"same_as_default": "apu_core_rw"},
        {"same_as_default": "bootmedia"},
        {"same_as_default": "PLM_image_store"},
        {"same_as_default": "PLM_in_place_update"},
        {"same_as_default": "PMC_ASU_RAM"},
        {"same_as_default": "PMC_ASU"},
        {"same_as_default": "ASU"},
        {"same_as_default": "ASU_PLM"},
        {"same_as_default": "ASU_XMPU"},
        {"same_as_default": "ASU_key_vault"},
        {"same_as_default": "ASU_UART"},
        {"same_as_default": "ASU_PMC"},
        {"same_as_default": "ISP_TILE0_INST0"},
        {"same_as_default": "ISP_TILE0_dynamic"},
        {"same_as_default": "ISP_TILE0_INST1"},
        {"same_as_default": "ISP_TILE1_INST0"},
        {"same_as_default": "ISP_TILE1_dynamic"},
        {"same_as_default": "ISP_TILE1_INST1"},
        {"same_as_default": "ISP_TILE2_INST0"},
        {"same_as_default": "ISP_TILE2_dynamic"},
        {"same_as_default": "ISP_TILE2_INST1"}
      ],
      "units": {
        "/NoC_C0_C1/ddrmc": {
          "root_access": "firmware_and_cci",
          "flags": {}
        },
        "/NoC_C2_C3/ddrmc": {
          "root_access": "firmware_and_cci",
          "flags": {}
        },
        "/NoC_C4/ddrmc": {
          "root_access": "firmware_and_cci",
          "flags": {}
        },
        "ASU": {"same_as_default": true},
        "ASU_XMPU": {"same_as_default": true},
        "FPD_AFIFS_XMPU": {"same_as_default": true},
        "FPD_ASIL_B_XMPU": {"same_as_default": true},
        "FPD_ASIL_D_XMPU": {"same_as_default": true},
        "FPD_CMN_XMPU": {"same_as_default": true},
        "FPD_MMU_XMPU": {"same_as_default": true},
        "IPI": {"same_as_default": true},
        "IPI_PERM": {"same_as_default": true},
        "ISP0_XMPU": {"same_as_default": true},
        "ISP1_XMPU": {"same_as_default": true},
        "ISP2_XMPU": {"same_as_default": true},
        "LPD_AFIFS_XMPU": {"same_as_default": true},
        "LPD_EM": {"same_as_default": true},
        "LPD_SLCR_SECURE": {"same_as_default": true},
        "LPD_XPPU": {"same_as_default": true},
        "MMI_XMPU": {"same_as_default": true},
        "OCM0_XMPU": {"same_as_default": true},
        "OCM1_XMPU": {"same_as_default": true},
        "OCM2_XMPU": {"same_as_default": true},
        "OCM3_XMPU": {"same_as_default": true},
        "OCM_TCM_XMPU": {"same_as_default": true},
        "OCM_XMPU": {"same_as_default": true},
        "PLM": {"same_as_default": true},
        "PMC_EM": {"same_as_default": true},
        "PMC_XMPU": {"same_as_default": true},
        "PMC_XMPU_CFU": {"same_as_default": true},
        "PMC_XMPU_SBI": {"same_as_default": true},
        "PMC_XPPU": {"same_as_default": true},
        "PMC_XPPU_NPI": {"same_as_default": true},
        "SECURE_REG_ACCESS": {"same_as_default": true},
        "SW_EM": {
          "flags": {"HB_MON_0": "srst"}
        }
      }
    },
    "subsystems": {
      "apu_subsys_linux": {
        "id": "0x1c000006",
        "access": [
          {
            "name": "UART",
            "destinations": ["UART0", "UART1"],
            "flags": {"requested": true, "requested_emit_wakeup": true, "requested_full_access": true, "requested_preserve_context": true, "shared": true}
          },
          {
            "name": "BOOT_MEDIA",
            "destinations": ["EMMC", "OSPI", "QSPI", "SD"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "USB",
            "comment": "EDF YOCTO",
            "destinations": ["USB0_CSR", "USB1_CSR"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "SPI",
            "comment": "EDF YOCTO",
            "destinations": ["SPI0", "SPI1"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "CAN",
            "comment": "EDF YOCTO",
            "destinations": ["CANFD0", "CANFD1", "CANFD2", "CANFD3"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "ETHERNET",
            "comment": "EDF YOCTO",
            "destinations": ["GEM0", "GEM1"],
            "flags": {"requested": true, "requested_coherent": true, "requested_emit_wakeup": true, "requested_full_access": true, "requested_preserve_context": true, "requested_virtualized": true, "shared": true}
          },
          {
            "name": "DMA",
            "comment": "LINUX",
            "destinations": [
              "LPD_DMA0_CH0",
              "LPD_DMA0_CH1",
              "LPD_DMA0_CH2",
              "LPD_DMA0_CH3",
              "LPD_DMA0_CH4",
              "LPD_DMA0_CH5",
              "LPD_DMA0_CH6",
              "LPD_DMA0_CH7"
            ],
            "flags": {"requested": true, "requested_coherent": true, "requested_full_access": true, "requested_virtualized": true, "shared": true}
          },
          {
            "name": "TTC",
            "comment": "EDF YOCTO",
            "destinations": [
              "TTC0",
              "TTC1",
              "TTC2",
              "TTC3",
              "TTC4",
              "TTC5",
              "TTC6",
              "TTC7"
            ],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "GPIO",
            "comment": "EDF YOCTO",
            "destinations": ["PMC_GPIO"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "SWDT",
            "comment": "EDF YOCTO",
            "destinations": ["APU_A_SWDT", "APU_B_SWDT", "APU_C_SWDT", "APU_D_SWDT"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "IPI0",
            "comment": "LINUX",
            "destinations": ["IPI0"],
            "flags": {"requested": true}
          },
          {
            "name": "I3C",
            "comment": "LINUX",
            "destinations": ["LPD_I3C0", "LPD_I3C1"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "MMI_GEM",
            "comment": "EDF YOCTO",
            "destinations": ["MMI_PCIEGEM_10GBE"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "MMI_USB",
            "comment": "EDF YOCTO",
            "destinations": ["MMI_USB_CFG"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "MMI_DC",
            "comment": "EDF YOCTO",
            "destinations": ["MMI_DC"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "ACPU",
            "comment": "All APU Cores (Linux)",
            "type": "cpu_list",
            "SMIDs": ["APU_A0", "APU_A1", "APU_B0", "APU_B1", "APU_C0", "APU_C1", "APU_D0", "APU_D1"]
          },
          {
            "name": "RESETS",
            "comment": "<TBD>",
            "destinations": [
              "RST_NOC",
              "RST_NOC_POR",
              "RST_NPI",
              "RST_PL0",
              "RST_PL1",
              "RST_PL2",
              "RST_PL3",
              "RST_PL_POR",
              "RST_PL_SRST",
              "RST_PMC",
              "RST_PMC_POR",
              "RST_SYS_RST_1",
              "RST_SYS_RST_2",
              "RST_SYS_RST_3"
            ],
            "type": "ss_management",
            "flags": {"shared": true}
          },
          {
            "name": "HB_MON0",
            "comment": "Wait for 120seconds before Healthy Boot Trigger",
            "destinations": ["HB_MON0"],
            "type": "ss_management",
            "flags": {"requested": true, "timeout": 120000}
          },
          {
            "name": "HB_MON1",
            "comment": "Wait for 240seconds before Healthy Boot Trigger",
            "destinations": ["HB_MON1"],
            "type": "ss_management",
            "flags": {"ignore": true, "requested": true, "timeout": 240000}
          },
          {
            "name": "LPD_GPIO",
            "comment": "EDF YOCTO",
            "destinations": ["LPD_GPIO"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "RTC",
            "destinations": ["PMC_RTC"],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "MEM_CTRL",
            "destinations": ["DDR0"],
            "type": "ss_management",
            "flags": {"shared": true}
          },
          {
            "name": "UFS",
            "destinations": ["UFS_XHCI"],
            "flags": {"requested": true, "requested_coherent": true, "requested_full_access": true, "requested_virtualized": true, "shared": true}
          }
        ]
      },
      "rpu_subsys_bm": {
        "id": "0x1c000007",
        "access": [
          {
            "name": "RPU",
            "comment": "RPU Cluster 1 (Baremetal)",
            "type": "cpu_list",
            "flags": {"coherent": true},
            "SMIDs": ["RPU_B"]
          },
          {
            "name": "IPI",
            "destinations": ["IPI2"],
            "flags": {"requested": true}
          }
        ]
      }
    }
  }
}