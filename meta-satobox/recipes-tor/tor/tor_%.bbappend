FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://tor-tmp.conf"

do_install:append() {

    # disable all HiddenServicePort entries in torrc
    sed -i 's|^HiddenService|#HiddenService|g' ${D}${sysconfdir}/tor/torrc

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 644 ${WORKDIR}/tor-tmp.conf ${D}${sysconfdir}/tmpfiles.d/
}

FILES:${PN} += "${sysconfdir}/tmpfiles.d"
