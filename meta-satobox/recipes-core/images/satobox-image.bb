DESCRIPTION = "Satobox Image"

inherit core-image passwd

# for mainnet configuration remove debug tools, ssh and package management
EXTRA_IMAGE_FEATURES:append = "${@bb.utils.contains('DISTRO_FEATURES', 'mainnet', '', ' debug-tweaks', d)}"
IMAGE_FEATURES:append = " read-only-rootfs"
IMAGE_FEATURES:append = "${@bb.utils.contains('DISTRO_FEATURES', 'mainnet', '', ' package-management ssh-server-openssh', d)}"

IMAGE_INSTALL:append= "\
    packagegroup-core-boot \
    ${CORE_IMAGE_BASE_INSTALL} \
    iptables \
    tzdata \
    nginx \
    hostname-setup \
    usbguard \
    python3-cryptoadvance-specter \
    bitcoin \
    electrs \
    "

DEV_TOOLS = "\
	packagegroup-core-full-cmdline \
    htop \
    tcpdump \
    gdbserver \
    strace \
    curl \
    iperf3 \
    sqlite3 \
    systemd-analyze \
	"

IMAGE_INSTALL:append = "${@bb.utils.contains('DISTRO_FEATURES', 'mainnet', '', " ${DEV_TOOLS}", d)}"

