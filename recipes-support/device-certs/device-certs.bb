SUMMARY = "Device certificates for Satobox"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = " \
           file://ca-cert.pem \
           file://ca-key.pem \
           file://device-certs.sh \
           file://device-certs.service \
           "

inherit systemd

RDEPENDS:${PN} += "openssl-bin hostname-setup ca-certificates"

do_install () {
    install -d ${D}${bindir} ${D}${sysconfdir}/certs
    install -m 0644 ${WORKDIR}/ca-cert.pem  ${D}${sysconfdir}/certs
    install -m 0644 ${WORKDIR}/ca-key.pem   ${D}${sysconfdir}/certs
    install -m 0755 ${WORKDIR}/device-certs.sh ${D}${bindir}/device-certs
}

FILES:${PN} = "${bindir} ${sysconfdir}/certs"

SYSTEMD_SERVICE:${PN} = "device-certs.service"
SYSTEMD_PACKAGES = "${PN}"

do_install:append() {
	install -d ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/device-certs.service ${D}${systemd_unitdir}/system/
}
