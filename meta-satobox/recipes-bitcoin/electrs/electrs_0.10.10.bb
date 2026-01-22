SUMMARY = "An efficient re-implementation of Electrum Server in Rust"
HOMEPAGE = "https://github.com/romanz/electrs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=87a20fcefe955de4146f08022c84319c"

SRC_URI = "git://github.com/romanz/electrs.git;protocol=https;branch=master \
           file://electrs.service.in \
           file://config.toml \
           "
# Tag 0.10.10
SRCREV = "1d9c4b8bb6fef23b128961fd6cdb291c52025010"
S = "${WORKDIR}/git"

TOOLCHAIN = "clang"

inherit cargo cargo-update-recipe-crates

require ${BPN}-crates.inc

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)}
SYSTEMD_SERVICE:${PN} = "electrs.service"
SYSTEMD_PACKAGES = "${PN}"

do_install:append() {

    install -d ${D}${sysconfdir}/electrs
    install -m 0644 ${WORKDIR}/config.toml ${D}${sysconfdir}/electrs/config.toml

    # Configure for mainnet if DISTRO_FEATURES is set
    if ${@bb.utils.contains('DISTRO_FEATURES', 'mainnet', 'true', 'false', d)}; then
        sed -i 's|^network = "signet"|network = "bitcoin"|' ${D}${sysconfdir}/electrs/config.toml
        sed -i 's|daemon_rpc_addr = "127.0.0.1:38332"|daemon_rpc_addr = "127.0.0.1:8332"|' ${D}${sysconfdir}/electrs/config.toml
        sed -i 's|daemon_p2p_addr = "127.0.0.1:38333"|daemon_p2p_addr = "127.0.0.1:8333"|' ${D}${sysconfdir}/electrs/config.toml
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/electrs.service.in ${D}${systemd_system_unitdir}/electrs.service
        sed -i 's:@bindir@:${bindir}:' ${D}${systemd_system_unitdir}/electrs.service
    fi
}

FILES:${PN} += "${sysconfdir}/electrs"

RDEPENDS:${PN} += "bitcoin"
