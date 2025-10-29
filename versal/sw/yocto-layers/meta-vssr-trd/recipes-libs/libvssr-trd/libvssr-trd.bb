#
# This file is the libvssr-trd recipe.
#

SUMMARY = "Vssr TRD library"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS += "packagegroup-petalinux-python-modules"
DEPENDS += "python3"
DEPENDS += "packagegroup-python3-jupyter"
DEPENDS += "python3-pybind11"
DEPENDS += "libapu-shmem"

SRC_URI = " file://funcs.cpp \
           file://funcs.hpp \
           file://bind.cpp \
           file://vssr-design.cpp \
           file://vssr-design.hpp \
           file://setup.py \
		  "
inherit setuptools3

S = "${WORKDIR}"

RM_WORK_EXCLUDE += "${PN}"
