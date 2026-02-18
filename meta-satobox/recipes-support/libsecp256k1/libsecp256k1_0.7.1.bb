DESCRIPTION = "Optimized C library for EC operations on curve secp256k1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=67330c75f8bf6a92f6f8a36ae669ba74"

SRC_URI = "git://github.com/bitcoin-core/secp256k1.git;branch=master;protocol=https"

#0.7.1
SRCREV = "1a53f4961f337b4d166c25fce72ef0dc88806618"
S = "${WORKDIR}/git"

inherit cmake pkgconfig

# Assembly optimization detection
def get_secp256k1_asm(d):
    arch = d.getVar('TARGET_ARCH')
    if arch in ['x86_64', 'amd64']:
        return 'x86_64'
    elif arch in ['arm', 'armv7', 'armv7a', 'armv7l']:
        return 'arm32'
    else:
        # For aarch64 and other architectures, use AUTO
        return 'AUTO'

SECP256K1_ASM = "${@get_secp256k1_asm(d)}"

EXTRA_OECMAKE = "-DSECP256K1_BUILD_BENCHMARK=ON \
                 -DSECP256K1_BUILD_TESTS=ON \
                 -DSECP256K1_BUILD_EXHAUSTIVE_TESTS=OFF \
                 -DSECP256K1_BUILD_CTIME_TESTS=OFF \
                 -DSECP256K1_BUILD_EXAMPLES=ON \
                 -DSECP256K1_ASM=${SECP256K1_ASM}"

do_install:append () {
    install -d ${D}${bindir}
    for f in ${B}/bin/*; do
        install -m 0755 $f  ${D}${bindir}/secp256k1_$(basename $f)
    done
}

PACKAGES =+ "${PN}-examples"
RDEPENDS:${PN}-examples += "${PN}"
FILES:${PN}-examples = "${bindir}"

BBCLASSEXTEND = "native nativesdk"
