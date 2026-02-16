FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://0002-rpi5-increase-the-kernel-load-address-for-fitImage.patch"

SRC_URI += "file://fitimage.cfg \
            file://harden.cfg \
            file://bootcount.cfg \
            file://environments.cfg \
           "

inherit uboot-sign
