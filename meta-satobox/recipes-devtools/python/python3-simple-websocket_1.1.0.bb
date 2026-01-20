SUMMARY = "Simple WebSocket server and client for Python"
HOMEPAGE = "https://github.com/miguelgrinberg/simple-websocket"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit python_setuptools_build_meta

SRC_URI = "https://files.pythonhosted.org/packages/b0/d4/bfa032f961103eba93de583b161f0e6a5b63cebb8f2c7d0c6e6efe1e3d2e/simple_websocket-1.1.0.tar.gz"
SRC_URI[sha256sum] = "7939234e7aa067c534abdab3a9ed933ec9ce4691b0713c78acb195560aa52ae4"

S = "${WORKDIR}/simple_websocket-1.1.0"

DEPENDS += "python3-setuptools-native python3-native"

RDEPENDS:${PN} += " \
    python3-core \
    python3-wsproto \
"
