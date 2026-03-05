FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit kernel-modsign 

SRC_URI += "file://dm-crypt-verity.cfg \
            file://ima-evm.cfg \
            file://kmod-sign.cfg \
            file://netfilter.scc \
            file://netfilter.cfg \
            "

KERNEL_FEATURES:append = " netfilter.scc"
