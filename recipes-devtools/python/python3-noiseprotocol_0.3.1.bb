SUMMARY = "Noise Protocol Framework - Python 3 implementation"
HOMEPAGE = "https://github.com/plizonczyk/noiseprotocol"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PYPI_PACKAGE = "noiseprotocol"

inherit pypi setuptools3

SRC_URI[sha256sum] = "b092a871b60f6a8f07f17950dc9f7098c8fe7d715b049bd4c24ee3752b90d645"

DEPENDS += " \
    python3-setuptools-native \
    python3-native \
"

RDEPENDS:${PN} += " \
    python3-core \
    python3-cryptography \
    python3-logging \
"

BBCLASSEXTEND = "native nativesdk"