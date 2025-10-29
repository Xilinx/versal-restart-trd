# Baremetal app name
APP = "hello-world"

FHW_DEPENDS = ""

FHW_MCDEPENDS = "mc::${MACHINE}-cortexr52-1-baremetal:${APP}:do_deploy"
DEPENDS:remove = "${APP}"
do_compile[mcdepends] += "${FHW_MCDEPENDS}"

FHW_DEPLOY_DIR = "${TMPDIR}-${MACHINE}-cortexr52-1-baremetal/deploy/images/${MACHINE}"
BIF_PARTITION_ATTR:append = " ${APP}"

# over-write r52 core-cluster in .bif file
BIF_PARTITION_ATTR[hello-world] = "destination_cpu=r52-1"
# over-write rpu app .elf in .bif file
BIF_PARTITION_IMAGE[hello-world] = "${FHW_DEPLOY_DIR}/${APP}-${MACHINE}-${MACHINE}-cortexr52-1-baremetal.elf"
# over-write RPU with custom Subsystem ID
BIF_PARTITION_ID[hello-world] = "0x1c000006"
