DESCRIPTION = "Satobox Base Image"

inherit core-image passwd

EXTRA_IMAGE_FEATURES = "debug-tweaks"
IMAGE_FEATURES += "package-management ssh-server-openssh"

IMAGE_INSTALL += "\
    packagegroup-core-boot \
    packagegroup-core-full-cmdline \
    ${CORE_IMAGE_BASE_INSTALL} \
    htop \
    tcpdump \
    gdbserver \
    strace \
    nginx \
    curl \
    openssl-bin \
    iperf3 \
    iptables \
    "

IMAGE_INSTALL += "\
    resize-part \
    hostname-setup \
    nodejs \
    nodejs-npm \
    bitcoin \
    "

ROOT_PASSWORD   = "r00t"
