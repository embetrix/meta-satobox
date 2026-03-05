inherit kernel-modsign uboot-config

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://dm-crypt-verity.cfg \
            file://ima-evm.cfg \
            file://kmod-sign.cfg \
            file://netfilter.cfg \
            file://security-harden.cfg \
            "

# On Raspberry Pi the firmware loads from the boot partition 
# the DTB produced by the kernel build ! 
# So the DTB U-Boot receives is the kernel-generated DTB one not a U-Boot DTB !
# That’s why we inject the FIT public keys into those kernel DTBs in the deploy step 
# so that U-Boot can verify the FIT image signature correctly:
# https://docs.u-boot.org/en/latest/board/broadcom/raspberrypi.html
do_deploy:append() {

    if [ "${UBOOT_SIGN_ENABLE}" != "1" ]; then
        return
    fi

    if ! ${@bb.utils.contains('KERNEL_IMAGETYPES', 'fitImage', 'true', 'false', d)}; then
        return
    fi

    if [ -z "${UBOOT_SIGN_KEYDIR}" ] || [ ! -d "${UBOOT_SIGN_KEYDIR}" ]; then
        return
    fi

    deployDir="${DEPLOYDIR}${@'/' + d.getVar('KERNEL_DEPLOYSUBDIR') if d.getVar('KERNEL_DEPLOYSUBDIR') else ''}"

    if [ ! -e "${deployDir}/fitImage" ]; then
        return
    fi

    if [ -z "${RPI_KERNEL_DEVICETREE}" ]; then
        bbwarn "RPI_KERNEL_DEVICETREE is empty; no DTBs to inject keys into"
        return
    fi

    for dtb in ${RPI_KERNEL_DEVICETREE}; do
        dtb_base="${dtb##*/}"

        if [ -e "${deployDir}/${dtb_base}" ]; then
            dtb_path="${deployDir}/${dtb_base}"
        elif [ -e "${deployDir}/${dtb_base%.dtb}-${MACHINE}.dtb" ]; then
            dtb_path="${deployDir}/${dtb_base%.dtb}-${MACHINE}.dtb"
        else
            bbwarn "DTB ${dtb_base} not present in ${deployDir}"
            continue
        fi

        bbnote "Injecting FIT signing public keys into ${dtb_path}"

        ${UBOOT_MKIMAGE_SIGN} \
            ${@'-D "${UBOOT_MKIMAGE_DTCOPTS}"' if len('${UBOOT_MKIMAGE_DTCOPTS}') else ''} \
            -F -k "${UBOOT_SIGN_KEYDIR}" \
            -K "${dtb_path}" \
            -r "${deployDir}/fitImage" \
            ${UBOOT_MKIMAGE_SIGN_ARGS}
    done
}
