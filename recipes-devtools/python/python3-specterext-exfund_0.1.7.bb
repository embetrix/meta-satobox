SUMMARY = "Specter Desktop extension to fund multiple addresses in one go"
HOMEPAGE = "https://github.com/stepansnigirev/specterext-exfund"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit setuptools3

SRC_URI = "https://files.pythonhosted.org/packages/fb/97/463d019ae27364ed77aeb3bc82d9129b0509e8298263bb37eb5c75d27cf0/specterext_exfund-0.1.7.tar.gz"
SRC_URI[sha256sum] = "d686e2d0c35064265f2ecebd71d906825ad1c917046e494526a12e80539de7f3"

S = "${WORKDIR}/specterext_exfund-0.1.7"

DEPENDS += "python3-setuptools-native python3-native"

RDEPENDS:${PN} += " \
    python3-core \
    python3-cryptoadvance-specter \
"
