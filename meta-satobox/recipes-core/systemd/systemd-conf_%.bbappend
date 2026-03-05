FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
	file://20-ethernet.network \
	file://80-wifi.network \
	file://90-security.conf \
	"

do_install() {
	install -d ${D}/${systemd_unitdir}/network
	install -m 644 ${WORKDIR}/20-ethernet.network ${D}/${systemd_unitdir}/network/
	install -m 644 ${WORKDIR}/80-wifi.network     ${D}/${systemd_unitdir}/network/

	install -d ${D}${sysconfdir}/sysctl.d
	install -m 644 ${WORKDIR}/90-security.conf ${D}${sysconfdir}/sysctl.d/
}

FILES:${PN} += "${systemd_unitdir}/network ${sysconfdir}/sysctl.d"
