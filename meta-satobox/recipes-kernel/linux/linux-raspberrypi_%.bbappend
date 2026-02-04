# Inject U-Boot FIT signing public keys into Raspberry Pi firmware DTBs
inherit uboot-config

do_deploy:append() {

    if [ "${UBOOT_SIGN_ENABLE}" != "1" ]; then
        return
    fi

    if ! echo ${KERNEL_IMAGETYPES} | grep -wq "fitImage"; then
        return
    fi

    if [ -z "${UBOOT_SIGN_KEYDIR}" ] || [ ! -d "${UBOOT_SIGN_KEYDIR}" ]; then
        return
    fi

    deployDir="${DEPLOYDIR}"
    if [ -n "${KERNEL_DEPLOYSUBDIR}" ]; then
        deployDir="${DEPLOYDIR}/${KERNEL_DEPLOYSUBDIR}"
    fi

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
