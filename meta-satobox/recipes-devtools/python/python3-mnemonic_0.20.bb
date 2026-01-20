SUMMARY = "Implementation of Bitcoin BIP-0039"
HOMEPAGE = "https://github.com/trezor/python-mnemonic"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=47284558328af55c15e2ee19ee17e912"

SRC_URI = "https://files.pythonhosted.org/packages/source/m/mnemonic/mnemonic-${PV}.tar.gz"

SRC_URI[sha256sum] = "7c6fb5639d779388027a77944680aee4870f0fcd09b1e42a5525ee2ce4c625f6"

inherit pypi setuptools3

RDEPENDS:${PN} += " \
    python3-core \
    python3-io \
    python3-logging \
"
