#
# This file is the vssr-test recipe.
#

SUMMARY = "Simple vssr-test application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://vssr-test.py \
	"

RDEPENDS_${PN} = "python3-core"

S = "${WORKDIR}"

do_install() {
	     install -d ${D}/${bindir}
	     install -m 0755 ${S}/vssr-test.py ${D}/${bindir}/vssr-test
}
