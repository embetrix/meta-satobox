SUMMARY = "An efficient re-implementation of Electrum Server in Rust"
HOMEPAGE = "https://github.com/romanz/electrs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=87a20fcefe955de4146f08022c84319c"

SRC_URI = "git://github.com/romanz/electrs.git;protocol=https;branch=master \
           file://electrs.service.in \
           file://config.toml \
           "
SRCREV = "ef83fef2b6323c2ba9763a0f6707fbd0f3dfed87"
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

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/electrs.service.in ${D}${systemd_system_unitdir}/electrs.service
        sed -i 's:@bindir@:${bindir}:' ${D}${systemd_system_unitdir}/electrs.service
    fi
}

FILES:${PN} += "${sysconfdir}/electrs"
