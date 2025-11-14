DESCRIPTION = "Versal SubSystem Restart TRD related Packages"


PACKAGE_ARCH = "${TUNE_PKGARCH}"
inherit packagegroup

RDEPENDS:${PN} = "  \
	packagegroup-petalinux-python-modules \
	python3 \
	python3-dev \
	packagegroup-python3-jupyter \
	python3-jupyterlab-widgets \
	python3-ipywidgets \
	python3-markdown \
	python3-pybind11 \
	nodejs \
	nodejs-npm \
	haveged \
	libapu-shmem \
	libvssr-trd \
	start-jupyterlab \
	vssr-trd-notebooks \
	watchdog-daemon \
	watchdog-daemon-init \
	vssr-test \
	"
