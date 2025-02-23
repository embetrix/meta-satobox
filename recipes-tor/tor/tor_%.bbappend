FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://tor-tmp.conf"

do_install:append() {
          
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 644 ${WORKDIR}/tor-tmp.conf ${D}${sysconfdir}/tmpfiles.d/
}

FILES:${PN} += "${sysconfdir}/tmpfiles.d"
