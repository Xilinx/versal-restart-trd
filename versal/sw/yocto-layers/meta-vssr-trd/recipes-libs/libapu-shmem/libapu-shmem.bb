#
# This file is the libapu-shmem recipe.
#

SUMMARY = "libapu-shmem library to communicate with RPU over libmetal shared memory"
SECTION = "libs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = " \
          file://apu-shmem.c \
          file://apu-shmem.h \
          file://Makefile \
         "

S = "${WORKDIR}"

PACKAGE_ARCH = "${MACHINE_ARCH}"
PROVIDES = "apu-shmem"
TARGET_CC_ARCH += "${LDFLAGS}"

DEPENDS += "libmetal"


TARGET_LDFLAGS += "-lmetal \
"-lpthread" \
"

do_install() {
    install -d ${D}${libdir}
    install -d ${D}${includedir}
    oe_libinstall -so libapu-shmem ${D}${libdir}
    install -d -m 0655 ${D}${includedir}/apu-shmem
    install -m 0644 ${S}/*.h ${D}${includedir}/apu-shmem/
}

FILES:${PN} = "${libdir}/*.so.* ${includedir}/*"
FILES:${PN}-dev = "${libdir}/*.so"
