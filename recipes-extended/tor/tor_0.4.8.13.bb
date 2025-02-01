SUMMARY = "Tor core"
DESCRIPTION = "Tor protects your privacy on the internet by hiding the connection between \
your Internet address and the services you use if configured properly."
HOMEPAGE = "https://www.torproject.org"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=fd51c8540e62d9458acf2e5c6e8ce350"

SRC_URI = "git://gitlab.torproject.org/tpo/core/${BPN};branch=release-0.4.8;protocol=https \
           file://tor.service.in \
           file://torrc \
           "
SRCREV = "e153e72c01315f86c1df36cecfa1790779a3adb4"
S = "${WORKDIR}/git"

DEPENDS = "openssl libevent"
inherit autotools pkgconfig

PACKAGECONFIG ??= "systemd zstd lzma"
PACKAGECONFIG[systemd] = "--enable-systemd,--disable-systemd, systemd"
PACKAGECONFIG[zstd]    = "--enable-zstd,--disable-zstd, zstd"
PACKAGECONFIG[lzma]    = "--enable-lzma,--disable-lzma, xz"

EXTRA_OECONF += " --disable-tool-name-check --disable-manpage --disable-asciidoc --disable-html-manual --disable-unittests"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)}
SYSTEMD_SERVICE:${PN} = "tor.service"
SYSTEMD_PACKAGES = "${PN}"

do_install:append() {

    install -d ${D}${sysconfdir}/tor
    install -m 0644 ${WORKDIR}/torrc ${D}${sysconfdir}/tor/torrc

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/tor.service.in ${D}${systemd_system_unitdir}/tor.service
        sed -i 's:@bindir@:${bindir}:' ${D}${systemd_system_unitdir}/tor.service
    fi
}

FILES:${PN} += "${bindir} \
              ${sysconfdir}/tor \
              ${datadir}/tor \
              "

BBCLASSEXTEND = "native nativesdk"
