SUMMARY = "A Cython interface to the hidapi from signal11"
HOMEPAGE = "https://github.com/trezor/cython-hidapi"
LICENSE = "BSD-3-Clause | GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE-bsd.txt;md5=3f5e5d0434d4e3c679e71e02300c16f8"

SRC_URI = "https://files.pythonhosted.org/packages/source/h/hidapi/hidapi-${PV}.tar.gz"
SRC_URI[sha256sum] = "a7cb029286ced5426a381286526d9501846409701a29c2538615c3d1a612b8be"

inherit pypi setuptools3 pkgconfig

DEPENDS += " \
    libusb1 \
    python3-cython-native \
    python3-setuptools-scm-native \
"


RDEPENDS:${PN} += " \
    python3-core \
    libusb1 \
"

CFLAGS:append = " -I${STAGING_INCDIR}/libusb-1.0"

do_configure:prepend() {
    # Remove "chid.pxd" or 'chid.pxd', followed optionally by a comma
    sed -i "s/['\"]chid.pxd['\"],\?//g" ${S}/setup.py
}
