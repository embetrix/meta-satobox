FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RDEPENDS:${PN}:append = " device-certs"

SRC_URI += "file://restart.conf"

do_install:append() {

    install -d ${D}${systemd_unitdir}/system/nginx.service.d
    install -m 0644 ${WORKDIR}/restart.conf ${D}${systemd_unitdir}/system/nginx.service.d/
}

FILES:${PN} += "${systemd_unitdir}/system/nginx.service.d"
