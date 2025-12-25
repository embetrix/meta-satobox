SUMMARY = "The Database Toolkit for Python"
HOMEPAGE = "https://www.sqlalchemy.org/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "https://files.pythonhosted.org/packages/source/S/SQLAlchemy/SQLAlchemy-${PV}.tar.gz"
SRC_URI[sha256sum] = "6913b8247d8a292ef8315162a51931e2b40ce91681f1b6f18f697045200c4a30"

inherit pypi setuptools3

PYPI_PACKAGE = "SQLAlchemy"

S = "${WORKDIR}/SQLAlchemy-${PV}"

RDEPENDS:${PN} += " \
    python3-core \
    python3-typing-extensions \
"

BBCLASSEXTEND = "native nativesdk"
