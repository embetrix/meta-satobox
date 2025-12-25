SUMMARY = "Stem is a Python controller library for Tor"
HOMEPAGE = "https://stem.torproject.org/"
LICENSE = "LGPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e6a600fd5e1d9cbde2d983680233ad02"

SRC_URI = "https://files.pythonhosted.org/packages/source/s/stem/stem-${PV}.tar.gz"
SRC_URI[sha256sum] = "83fb19ffd4c9f82207c006051480389f80af221a7e4783000aedec4e384eb582"

inherit pypi setuptools3

RDEPENDS:${PN} += " \
    python3-core \
    python3-io \
    python3-logging \
    python3-netclient \
    python3-unittest \
"
