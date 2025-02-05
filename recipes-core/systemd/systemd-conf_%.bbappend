FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "\
	file://20-ethernet.network \
	file://80-wifi.network \
	"

do_install() {
	install -d ${D}/${systemd_unitdir}/network
	install -m 644 ${WORKDIR}/20-ethernet.network ${D}/${systemd_unitdir}/network/
	install -m 644 ${WORKDIR}/80-wifi              ${D}/${systemd_unitdir}/network/

}

FILES:${PN} += "${systemd_unitdir}/network"
