DESCRIPTION = "resize partition"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit systemd

SRC_URI = "file://resize-part.service \
           file://resize-part.sh"

SYSTEMD_SERVICE:${PN} = "resize-part.service"
SYSTEMD_PACKAGES = "${PN}"

do_install() {

	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/resize-part.sh ${D}${bindir}/resize-part
	install -d ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/resize-part.service ${D}${systemd_unitdir}/system/
}

RDEPENDS:${PN} += "util-linux-blkid e2fsprogs-mke2fs e2fsprogs-resize2fs parted gptfdisk"
