SUMMARY = "Flask-SQLAlchemy is an extension for Flask that adds support for SQLAlchemy"
HOMEPAGE = "https://flask-sqlalchemy.palletsprojects.com/"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = "https://files.pythonhosted.org/packages/c6/4e/0991354600fe3e1223cd9f025dbde900b1c1fe231762e18cdaffbe55938e/flask_sqlalchemy-3.0.5.tar.gz"
SRC_URI[sha256sum] = "c5765e58ca145401b52106c0f46178569243c5da25556be2c231ecc60867c5b1"

inherit  python_flit_core

S = "${WORKDIR}/flask_sqlalchemy-3.0.5"

RDEPENDS:${PN} += " \
    python3-core \
    python3-flask \
    python3-sqlalchemy \
"

