SUMMARY = "Adds APScheduler support to Flask"
HOMEPAGE = "https://github.com/viniciuschiele/flask-apscheduler"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=db1785bfcf1a1d78a205b6ad379a715d"
SRC_URI[sha256sum] = "681dae34dc6cc9403ce674795e53abd0bff540472129cfd3d3c93e0e1d502da8"

PYPI_PACKAGE = "Flask-APScheduler"

inherit pypi setuptools3

RDEPENDS:${PN} += " \
    python3-flask \
    python3-apscheduler \
    python3-dateutil \
"
