SUMMARY = "yet another bitcoin library"
HOMEPAGE = "https://github.com/diybitcoinhardware/embit"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=bbe06492d41a7500cf6616ec541ded06"

SRC_URI[sha256sum] = "16a84c6668dc9ffc907594457a46f7142cee379646bc009a5a9b77b0d2cb4e12"

inherit pypi setuptools3

RDEPENDS:${PN} += "python3-core"

PYPI_PACKAGE = "embit"

# Remove pre-compiled binaries for other architectures to fix build failure
do_install:append() {
    rm -rf ${D}${PYTHON_SITEPACKAGES_DIR}/embit/util/prebuilt
}
