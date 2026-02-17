FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://0001-rpi5-enforce-whitelist-of-env-variables.patch \
            file://0002-rpi5-increase-the-kernel-load-address-for-fitImage.patch \
            file://fw_env.config \
           "

SRC_URI += "file://fitimage.cfg \
            file://harden.cfg \
            file://bootcount.cfg \
            file://environments.cfg \
           "

inherit uboot-sign
