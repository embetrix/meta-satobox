SUMMARY = "Bitcoin Core integration"
HOMEPAGE = "https://bitcoincore.org"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=1bcc4deb6e65214278a39df8e5d29902"

SRCREV = "b432e367427f1f9fe0f0a5800e31e496f00cd38d"
SRC_URI = "git://github.com/bitcoin/bitcoin.git;branch=master;protocol=https \
           file://bitcoind.service.in \
           file://bitcoin.conf \
           file://bitcoin-tmp.conf \
           "

S = "${WORKDIR}/git"

COMPATIBLE_HOST:libc-musl = "null"

inherit pkgconfig cmake

DEPENDS = "libevent boost"

PACKAGECONFIG ?= "shared wallet zmq"
PACKAGECONFIG[shared] = "-DBUILD_SHARED_LIBS=ON, -DBUILD_SHARED_LIBS=OFF"
PACKAGECONFIG[man]    = "-DINSTALL_MAN=ON, -DINSTALL_MAN=OFF"
PACKAGECONFIG[wallet] = "-DENABLE_WALLET=ON, -DENABLE_WALLET=OFF, sqlite3"
PACKAGECONFIG[zmq]    = "-DWITH_ZMQ=ON, -DWITH_ZMQ=OFF, zeromq"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)}
SYSTEMD_SERVICE:${PN} = "bitcoind.service"
SYSTEMD_PACKAGES = "${PN}"

do_install:append() {

    install -d ${D}${sysconfdir}/bitcoin
    install -m 0644 ${WORKDIR}/bitcoin.conf ${D}${sysconfdir}/bitcoin/bitcoin.conf
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 644 ${WORKDIR}/bitcoin-tmp.conf ${D}${sysconfdir}/tmpfiles.d/bitcoin.conf

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/bitcoind.service.in ${D}${systemd_system_unitdir}/bitcoind.service
        sed -i 's:@bindir@:${bindir}:' ${D}${systemd_system_unitdir}/bitcoind.service
    fi
}

FILES:${PN} += "${sysconfdir}/bitcoin \
                ${sysconfdir}/tmpfiles.d \
                "

RDEPENDS:${PN} += "tor"

BBCLASSEXTEND = "native nativesdk"
