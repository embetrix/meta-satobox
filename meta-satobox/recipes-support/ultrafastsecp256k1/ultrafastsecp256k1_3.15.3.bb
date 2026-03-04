DESCRIPTION = "Ultra high-performance secp256k1 ECC library"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ac0d51f8d23d04ebe5cfd38b52618ce9"

SRC_URI = "git://github.com/shrec/UltrafastSecp256k1.git;branch=main;protocol=https"

#v3.15.3
SRCREV = "8cfcc471ff72522add72164b511b7476a9be632b"
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