SUMMARY = "Read key-value pairs from a .env file and set them as environment variables"
HOMEPAGE = "https://github.com/theskumar/python-dotenv"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e914cdb773ae44a732b392532d88f072"

SRC_URI = "https://files.pythonhosted.org/packages/source/p/python-dotenv/python-dotenv-${PV}.tar.gz"
SRC_URI[sha256sum] = "e324ee90a023d808f1959c46bcbc04446a10ced277783dc6ee09987c37ec10ca"

inherit pypi setuptools3

PYPI_PACKAGE = "python-dotenv"

RDEPENDS:${PN} += " \
    python3-core \
    python3-io \
"
