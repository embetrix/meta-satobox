SUMMARY = "Bitcoin Core integration"
HOMEPAGE = "https://bitcoincore.org"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=502a9495576ff2bb756c7a6abf0b85c0"

SRC_URI = "git://github.com/bitcoin/bitcoin.git;branch=30.x;protocol=https \
           file://0001-bitcoind-disable-noisy-UpdateTipLog-logs.patch \
           file://bitcoind.service.in \
           file://bitcoin.conf \
           file://bitcoin-tmp.conf \
           "
#v30.2
SRCREV = "4d7d5f6b79d4c11c47e7a828d81296918fd11d4d"
S = "${WORKDIR}/git"

TOOLCHAIN = "clang"

inherit pkgconfig cmake

DEPENDS =  "libevent boost"
DEPENDS += "doxygen-native"

EXTRA_OECMAKE += "-DBUILD_BENCH=OFF \
                  -DBUILD_TESTS=OFF \
                  -DBUILD_GUI=OFF \
                  -DENABLE_IPC=OFF"

PACKAGECONFIG ?= "shared wallet zmq"
PACKAGECONFIG[shared] = "-DBUILD_SHARED_LIBS=ON, -DBUILD_SHARED_LIBS=OFF"
PACKAGECONFIG[man]    = "-DINSTALL_MAN=ON, -DINSTALL_MAN=OFF"
PACKAGECONFIG[wallet] = "-DENABLE_WALLET=ON, -DENABLE_WALLET=OFF, sqlite3"
PACKAGECONFIG[zmq]    = "-DWITH_ZMQ=ON, -DWITH_ZMQ=OFF, zeromq"


inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "--system bitcoin"
USERADD_PARAM:${PN}  = "--system  --no-create-home -g bitcoin -s /bin/false bitcoin"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)}
SYSTEMD_SERVICE:${PN} = "bitcoind.service"
SYSTEMD_PACKAGES = "${PN}"

BITCOIND_RPC_USER   ?= "satobox"
BITCOIND_RPC_PASSWD ?= "sat0b0x"

do_install:append() {

    install -d ${D}${sysconfdir}/bitcoin
    install -m 0644 ${WORKDIR}/bitcoin.conf ${D}${sysconfdir}/bitcoin/bitcoin.conf
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 644 ${WORKDIR}/bitcoin-tmp.conf ${D}${sysconfdir}/tmpfiles.d/bitcoin.conf

    # Generate RPC auth hash using the script in Bitcoin source
    RPC_AUTH_HASH=$(${S}/share/rpcauth/rpcauth.py ${BITCOIND_RPC_USER} ${BITCOIND_RPC_PASSWD} | grep "rpcauth=" | cut -d'=' -f2-)
    sed -i "s|^rpcauth=.*|rpcauth=${RPC_AUTH_HASH}|" ${D}${sysconfdir}/bitcoin/bitcoin.conf

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/bitcoind.service.in ${D}${systemd_system_unitdir}/bitcoind.service
        sed -i 's:@bindir@:${bindir}:' ${D}${systemd_system_unitdir}/bitcoind.service
    fi
}

FILES:${PN} += "${sysconfdir}/bitcoin \
                ${sysconfdir}/tmpfiles.d \
                "

RDEPENDS:${PN} += "tor python3-hwi"

BBCLASSEXTEND = "native nativesdk"
