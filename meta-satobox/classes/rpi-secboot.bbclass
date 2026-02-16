# This class tries to mimic sdcard_image-rpi.bbclass but generates only boot.img
# instead of a full SD card image with rootfs partition.
# It creates a standalone bootable FAT32 partition image containing
# bootloader files, kernel, device trees, and overlays.
# When secure boot is enabled, it also generates a signature file boot.sig along side with boot.img
#
# Usage:
#   To enable secure boot signing, set in your machine, distro, or local config:
#     RPI_SECBOOT_SIGN = "1"
#     RPI_SECBOOT_SIGN_KEY = "/path/to/keys/secure-boot-sign.key"
#
#   The signing key must be an RSA 2048-bit
#
#   To deploy boot.img/boot.sig to the boot partition via wic add:
#     IMAGE_BOOT_FILES:append = " boot.img boot.sig"
#   This is backward compatible if secure boot is not enabled, the system
#   will still boot from files in the FAT partition.
#
#   For strict secure boot (boot only from signed boot.img), use:
#     IMAGE_BOOT_FILES = "boot.img boot.sig"
#
inherit image_types

# Enable signing of boot.img in deploy directory.
RPI_SECBOOT_SIGN ?= "0"

# Space-separated list of files to remove from boot.img after it is populated
SECBOOT_FILES_EXCLUDE ?= ""

# Boot image/signature name
RPI_SECBOOTIMG = "${DEPLOY_DIR_IMAGE}/boot.img"
RPI_SECBOOTIMG_SIG = "${DEPLOY_DIR_IMAGE}/boot.sig"

do_image_rpi_secboot[depends] = " \
    mtools-native:do_populate_sysroot \
    dosfstools-native:do_populate_sysroot \
    virtual/kernel:do_deploy \
    rpi-bootfiles:do_deploy \
    ${@bb.utils.contains('RPI_SECBOOT_SIGN', '1', 'openssl-native:do_populate_sysroot', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'armstub', 'armstubs:do_deploy', '' ,d)} \
    ${@bb.utils.contains('RPI_USE_U_BOOT', '1', 'u-boot:do_deploy', '',d)} \
    ${@bb.utils.contains('RPI_USE_U_BOOT', '1', 'u-boot-default-script:do_deploy', '',d)} \
"

do_image_rpi_secboot[recrdeps] = "do_build"

# Ensure wic images depend on rpi-secboot image type when both are enabled.
IMAGE_TYPEDEP:wic += " rpi-secboot"

IMAGE_CMD:rpi-secboot () {

    # Check if we are building with device tree support
    DTS="${@make_dtb_boot_files(d)}"

    rm -f ${WORKDIR}/boot.img
    mkfs.vfat -F32 -n "${BOOTDD_VOLUME_ID}" -S 512 -C ${WORKDIR}/boot.img ${BOOT_SPACE}
    mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/* ::/ || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/* into boot.img"
    if [ "${@bb.utils.contains("MACHINE_FEATURES", "armstub", "1", "0", d)}" = "1" ]; then
        mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/armstubs/${ARMSTUB} ::/ || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/armstubs/${ARMSTUB} into boot.img"
    fi
    if test -n "${DTS}"; then
        mmd -i ${WORKDIR}/boot.img overlays
        for entry in ${DTS} ; do
            if [ $(echo "$entry" | grep -c \;) = "0" ] ; then
                DEPLOY_FILE="$entry"
                DEST_FILENAME="$entry"
            else
                DEPLOY_FILE="$(echo "$entry" | cut -f1 -d\;)"
                DEST_FILENAME="$(echo "$entry" | cut -f2- -d\;)"
            fi
            mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${DEPLOY_FILE} ::${DEST_FILENAME} || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/${DEPLOY_FILE} into boot.img"
        done
    fi
    if [ "${RPI_USE_U_BOOT}" = "1" ]; then
        mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/u-boot.bin ::${SDIMG_KERNELIMAGE} || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/u-boot.bin into boot.img"
        mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/boot.scr ::boot.scr || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/boot.scr into boot.img"
        if [ ! -z "${INITRAMFS_IMAGE}" -a "${INITRAMFS_IMAGE_BUNDLE}" = "1" ]; then
            mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${INITRAMFS_LINK_NAME}.bin ::${KERNEL_IMAGETYPE} || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${INITRAMFS_LINK_NAME}.bin into boot.img"
        else
            mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE} ::${KERNEL_IMAGETYPE} || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE} into boot.img"
        fi
    else
        if [ ! -z "${INITRAMFS_IMAGE}" -a "${INITRAMFS_IMAGE_BUNDLE}" = "1" ]; then
            mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${INITRAMFS_LINK_NAME}.bin ::${SDIMG_KERNELIMAGE} || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${INITRAMFS_LINK_NAME}.bin into boot.img"
        else
            mcopy -v -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE} ::${SDIMG_KERNELIMAGE} || bbfatal "mcopy cannot copy ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE} into boot.img"
        fi
    fi
    
    # Exclude files from boot.img if specified
    if [ -n "${SECBOOT_FILES_EXCLUDE}" ]; then
        for entry in ${SECBOOT_FILES_EXCLUDE} ; do
            mdel -i ${WORKDIR}/boot.img ::${entry} || bbfatal "mdel cannot remove ${entry} from boot.img"
        done
    fi

    cp ${WORKDIR}/boot.img ${RPI_SECBOOTIMG}

    # Generate signature file for boot.img if secure boot enabled. 
    # The signature format is :
    # <sha256-hex>
    # ts: <unix-epoch-seconds>
    # rsa2048: <rsa-pkcs1v1.5-sha256-signature-hex>
    if [ "${RPI_SECBOOT_SIGN}" = "1" ]; then
        if [ -f "${RPI_SECBOOT_SIGN_KEY}" ]; then
            {
                openssl dgst -sha256 ${RPI_SECBOOTIMG} | awk '{print $2}'
                echo "ts: $(date +%s)"
                printf "rsa2048: "
                openssl dgst -sha256 -sign ${RPI_SECBOOT_SIGN_KEY} ${RPI_SECBOOTIMG} \
                | hexdump -v -e '1/1 "%02x"'; echo

            } > ${RPI_SECBOOTIMG_SIG} || bbfatal "Failed to generate signature for ${RPI_SECBOOTIMG}"
        else
            bbwarn "${RPI_SECBOOT_SIGN_KEY} keyfile not found! skipping signing"
        fi
    fi
}
