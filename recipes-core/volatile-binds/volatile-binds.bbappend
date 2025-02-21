FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

VOLATILE_BINDS = "\
    /var/data/lib/systemd/network /lib/systemd/network\n\
    /var/data/home/root /home/root\n\
    /var/data/etc/wpa_supplicant /etc/wpa_supplicant\n\
    /var/data/etc/bitcoin /etc/bitcoin\n\
    /var/data/etc/tor /etc/tor\n\
    /var/data/var/tor /var/tor\n\
"
