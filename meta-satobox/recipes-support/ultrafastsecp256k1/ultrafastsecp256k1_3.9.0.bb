DESCRIPTION = "Ultra high-performance secp256k1 ECC library"
LICENSE = "AGPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=127e18a604ef7b91787b82648ee4c4a1"

SRC_URI = "git://github.com/shrec/UltrafastSecp256k1.git;branch=main;protocol=https"

#v3.9.0
SRCREV = "f650ccd3df1348f118b5dabb1b1d8c0837297fdf"
S = "${WORKDIR}/git"

inherit cmake pkgconfig

# Platform detection for optimized builds
def get_secp256k1_platform(d):
    arch = d.getVar('TARGET_ARCH')
    if arch in ['x86_64', 'amd64']:
        return 'x86_64'
    elif arch in ['aarch64', 'arm64']:
        return 'aarch64'
    elif arch == 'riscv64':
        return 'riscv64'
    else:
        return 'generic'

SECP256K1_PLATFORM = "${@get_secp256k1_platform(d)}"

EXTRA_OECMAKE = "-DSECP256K1_BUILD_CPU=ON \
                 -DSECP256K1_BUILD_TESTS=OFF \
                 -DSECP256K1_BUILD_BENCH=OFF \
                 -DSECP256K1_BUILD_EXAMPLES=ON \
                 -DSECP256K1_BUILD_SHARED=OFF \
                 -DSECP256K1_PLATFORM=${SECP256K1_PLATFORM}"

do_install:append () {
    install -d ${D}${bindir}
    install -m 0755 ${B}/examples/example_basic_usage  ${D}${bindir}/fastsecp256k1_example
}

PACKAGES =+ "${PN}-examples"
RDEPENDS:${PN}-examples += "${PN}"
FILES:${PN}-examples = "${bindir}"

ALLOW_EMPTY:${PN} = "1"

BBCLASSEXTEND = "native nativesdk"