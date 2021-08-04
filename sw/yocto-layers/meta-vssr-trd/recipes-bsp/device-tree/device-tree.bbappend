FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
			file://vssr.dtsi \
			file://reserved-mem.dtsi \
			file://libmetal-shm.dtsi \
			"

do_configure_append() {
	echo "/include/ \"vssr.dtsi\"" >> ${WORKDIR}/system-user.dtsi
}
