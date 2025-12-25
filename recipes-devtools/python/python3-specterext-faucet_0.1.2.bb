SUMMARY = "Specter Desktop extension with a regtest faucet and a miner"
HOMEPAGE = "https://github.com/stepansnigirev/specterext-faucet"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit setuptools3

SRC_URI = "https://files.pythonhosted.org/packages/94/fb/6a506e827642a1700bf53a1174dd74f57a3d3f91c4bc4efe0ad94e5def1e/specterext_faucet-0.1.2.tar.gz"
SRC_URI[sha256sum] = "86db78a6c41688152cfeec14efafd6d06c97e6edd9735461ee897495f90cb2e8"

S = "${WORKDIR}/specterext_faucet-0.1.2"

RDEPENDS:${PN} += "python3-cryptoadvance-specter"
