SUMMARY = "Generates boot.bin using bootgen tool"
DESCRIPTION = "Recipe over-writes the configurations of out-of-box versal-2ve-2vm machine in EDF Yocto"

# over-write APU Subsystem Configuration (Linux)
include versal-2ve-2vm-apu-subsys.inc

# over-write RPU Subsystem Configuration (Baremetal)
include versal-2ve-2vm-rpu-subsys.inc