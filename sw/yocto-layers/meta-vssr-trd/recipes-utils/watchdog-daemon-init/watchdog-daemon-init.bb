#
# This file is the watchdog-daemon-init recipe.
#
SUMMARY = "Simple watchdog-daemon-init application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM ="file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://watchdog-daemon-init \
 "
S = "${WORKDIR}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit update-rc.d

INITSCRIPT_NAME = "watchdog-daemon-init"
INITSCRIPT_PARAMS = "start 99 S ."

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${S}/watchdog-daemon-init ${D}${sysconfdir}/init.d/watchdog-daemon-init
}

FILES_${PN} += "${sysconfdir}/*"

