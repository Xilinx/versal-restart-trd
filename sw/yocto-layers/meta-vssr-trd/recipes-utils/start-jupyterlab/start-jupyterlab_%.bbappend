#
# This is the jupyter-lab startup daemon
#

SUMMARY = "Start Jupyter-lab server at system boot"

FILESEXTRAPATHS:prepend := "${THISDIR}/start-jupyterlab:"

SRC_URI:append = " \
	file://0001-recipe-utils-start-jupyterlab-Fix-IP-extraction.patch \
	file://0002-recipe-utils-start-jupyterlab-Update-to-root-user.patch \
	file://jupyter_lab_config.py \
	file://overrides-vssr.json \
	"

do_install:append() {
	rm -f ${D}${sysconfdir}/jupyter/jupyter_notebook_config.py

	install -d ${D}${sysconfdir}/jupyter/
	install -m 0600 ${WORKDIR}/jupyter_lab_config.py ${D}${sysconfdir}/jupyter/

	install -d ${D}${datadir}/jupyter/lab/settings
	install -m 0644 ${WORKDIR}/overrides-vssr.json ${D}${datadir}/jupyter/lab/settings/overrides.json
}

FILES_${PN}:append += " \
	${datadir}/jupyter/lab/settings \
	"
