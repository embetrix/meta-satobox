SUMMARY = "Pretty Good Privacy for Python"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=f02107d581e32c86d081ce7da3617396"

PYPI_PACKAGE = "PGPy"

inherit pypi setuptools3

SRC_URI = "https://files.pythonhosted.org/packages/source/P/${PYPI_PACKAGE}/${PYPI_PACKAGE}-${PV}.tar.gz"
SRC_URI[sha256sum] = "279c2e353f4c3a319f00bd9bd582456e420f8a3ac6de2b4e9731444746828383"

RDEPENDS:${PN} += "python3-core \
                   python3-cryptography \
                   python3-six \
                   python3-dateutil \
                   python3-pyasn1"
