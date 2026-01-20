SUMMARY = "Specter Extension: Spectrum"
HOMEPAGE = "https://pypi.org/project/cryptoadvance.spectrum/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit  setuptools3

SRC_URI = "https://files.pythonhosted.org/packages/6b/ed/b19dd8a3397053127d5d020274e5fbc7774d3fb3bef9dbff3db893de6a15/cryptoadvance.spectrum-0.6.4.tar.gz"
SRC_URI[sha256sum] = "fa6c877b3a5ba683ccde991f020fce2f3b06e0b8f5219a6fdc592658cacb1d3d"

S = "${WORKDIR}/cryptoadvance.spectrum-0.6.4"


SRC_URI += "\
    file://0001-Make-Spectrum-electrum-client-tolerant-to-electrs-in.patch \
    file://0002-spectrum-provide-stable-RPCError-import-path.patch \
    file://0003-spectrum-avoid-false-regtest-detection-on-mainnet-el.patch \
    file://0004-spectrum-if-electrum-is-not-yet-ready-add-chain-hint.patch \
"

DEPENDS += "python3-setuptools-native python3-native"

RDEPENDS:${PN} += " \
    python3-core \
    python3-cryptoadvance-specter \
    python3-embit \
    python3-flask \
    python3-flask-sqlalchemy \
    python3-sqlalchemy \
    python3-requests \
    python3-pysocks \
"
