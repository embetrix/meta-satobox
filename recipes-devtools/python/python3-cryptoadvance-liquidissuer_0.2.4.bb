SUMMARY = "Specter Extension: Liquid Issuer"
HOMEPAGE = "https://pypi.org/project/cryptoadvance-liquidissuer/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "https://files.pythonhosted.org/packages/62/da/defc136084f3b858b7b7bf32ef1ce8189818390e61fe1c97adddfd96c1e6/cryptoadvance_liquidissuer-0.2.4.tar.gz"
SRC_URI[sha256sum] = "9e468f3e35ecc566b3f74a2263677cf26632548abb194521dba15ad37acd1e9b"

inherit  setuptools3

S = "${WORKDIR}/cryptoadvance_liquidissuer-0.2.4"

DEPENDS += "python3-setuptools-native python3-native"

RDEPENDS:${PN} += " \
    python3-core \
    python3-cryptoadvance-specter \
    python3-flask \
    python3-embit \
"