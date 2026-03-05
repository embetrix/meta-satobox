FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

#SYSTEMD_AUTO_ENABLE:${PN} = "disable"

do_install:append() {
    # Remove  SSH rules for mainnet builds as SSH server is no part of the image
	if ${@bb.utils.contains('DISTRO_FEATURES', 'mainnet', 'true', 'false', d)}; then
		sed -i '/--dport 22/d' ${D}${sysconfdir}/${BPN}/iptables.rules
		if ${@bb.utils.contains('PACKAGECONFIG', 'ipv6', 'true', 'false', d)}; then
			sed -i '/--dport 22/d' ${D}${sysconfdir}/${BPN}/ip6tables.rules
		fi
	fi
}
