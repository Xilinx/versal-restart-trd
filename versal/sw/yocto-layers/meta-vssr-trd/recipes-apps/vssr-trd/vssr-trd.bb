#
# This is the base-trd recipe
#
#

SUMMARY = "VSSR TRD Jupyter notebooks"
SECTION = "PETALINUX/apps"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d5d667b6456b8f66689c5e3ae6f2287a"

RDEPENDS:${PN} += " \
	libvssr-trd \
	libapu-shmem \
	"

SRC_URI = " \
	file://notebooks \
	file://LICENSE \
	"

S = "${WORKDIR}"

do_configure[noexec]="1"
do_compile[noexec]="1"

NOTEBOOK_DIR = "${datadir}/notebooks"

do_install() {
	install -d ${D}/${NOTEBOOK_DIR}/${PN}
	cp -r ${S}/notebooks/* ${D}/${NOTEBOOK_DIR}/${PN}
}

FILES:${PN}-notebooks += "${NOTEBOOK_DIR}"
PACKAGES += "${PN}-notebooks"

