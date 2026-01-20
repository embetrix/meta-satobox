FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://aliases.sh"

#add mount points for data/bitcoin/wallets/backups partitions
dirs755 += " ${localstatedir}/data     \
             ${localstatedir}/bitcoin  \
             ${localstatedir}/wallets   \
             ${localstatedir}/backups  \
            "

do_compile[nostamp] = "1"

do_install:append() {
	install -d ${D}${sysconfdir}/profile.d
	install -m 0644 ${WORKDIR}/aliases.sh ${D}${sysconfdir}/profile.d/
}

FILES:${PN} += "${sysconfdir}/profile.d"
