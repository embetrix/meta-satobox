SUMMARY = "BitcoinLib provides developers with a wide range of tools to work with Bitcoin"
HOMEPAGE = "https://bitcoinlib.readthedocs.io"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3db23ab95801691a1b98ff9ddb8dc98b"

SRC_URI[sha256sum] = "bad50074e0027476251e31e5cedec206c6cea0febaafb8546251c66edba60f55"

PYPI_PACKAGE = "bitcoinlib"

DEPENDS += "gmp python3-setuptools-native"

inherit pypi python_flit_core

RDEPENDS:${PN} += "\
    sqlite3 \
    python3-sqlite3 \
    python3-ecdsa \
    python3-numpy \
    python3-cython \
    python3-pycryptodome \
    python3-sqlalchemy \
    python3-requests \
    "

BBCLASSEXTEND = "native nativesdk"
