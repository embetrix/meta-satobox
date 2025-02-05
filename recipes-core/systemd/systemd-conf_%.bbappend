FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "\
	file://80-wlan.network \
	"

do_install() {
	install -d ${D}/${systemd_unitdir}/network
	install -m 644 ${WORKDIR}/*.network ${D}/${systemd_unitdir}/network/

}

FILES:${PN} += "${systemd_unitdir}/network"
