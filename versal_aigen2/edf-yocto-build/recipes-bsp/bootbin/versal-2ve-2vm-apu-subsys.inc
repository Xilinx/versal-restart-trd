
# Specify BIF common attribute for FSBL
BIF_COMMON_ATTR ?= ""

# Specify BIF optional attributes
BIF_OPTIONAL_DATA ?= ""

# Specify BIF partition attributes required for BOOT.bin
BIF_FSBL_ATTR       ??= "base-pdi plmfw"
BIF_ATF_ATTR        ??= "arm-trusted-firmware"
BIF_OPTEE_ATTR      ??= "${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'optee-os', '', d)}"
BIF_ASU_ATTR        ??= ""
BIF_DEVICETREE_ATTR ??= "device-tree"
BIF_SSBL_ATTR       ??= "u-boot-xlnx"
BIF_PARTITION_ATTR  ??= "${BIF_FSBL_ATTR} ${BIF_ASU_ATTR} ${BIF_DEVICETREE_ATTR} ${BIF_ATF_ATTR} ${BIF_OPTEE_ATTR} ${BIF_SSBL_ATTR}"

# .bif file Image section name and Subsystem ID ( for APU running Linux )
BIF_PARTITION_NAME[0x1c000006] ?= "apu_ss"
# Custom Subsystem ID for Device Tree
BIF_PARTITION_ID[device-tree] = "0x1c000006"
# Custom Subsystem ID for u-boot
BIF_PARTITION_ID[u-boot-xlnx] = "0x1c000006"
# Custom Subsystem ID for TF-A
BIF_PARTITION_ID[arm-trusted-firmware] = "0x1c000006"
# Custom Subsystem ID for OPTEE
BIF_PARTITION_ID[optee-os] = "0x1c000006"
