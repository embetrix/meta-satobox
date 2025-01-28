#!/bin/sh
# Copyright 2025  Embetrix Embedded Systems Solutions, ayoub.zaki@embetrix.com
#

LABEL="bitcoin"
PART=$(blkid --label $LABEL)
PART_NBR=${PART##*p}
DEVICE="/dev/$(lsblk -no PKNAME $PART)"
SECTORS=$(blockdev --getsz $PART)
MIN_SEC=8388608   # 4GB in sectors
MESSAGE=""

if [ -z "$DEVICE" ] || [ -z "$PART" ] || [ -z "$PART_NBR" ]; then
    echo "No device found with label $LABEL"
    MESSAGE="No device found with label $LABEL!"
else
    if [ $SECTORS -lt $MIN_SEC ]; then
        echo "Resizing partition $PART"
        if grep -q "^$PART" /proc/mounts; then
            umount $PART
        fi
        sgdisk -d $PART_NBR -n $PART_NBR:0:0 -c $PART_NBR:$LABEL $DEVICE
        partprobe $DEVICE
        mkfs.ext4 -F $PART -L $LABEL
        mount -L $LABEL
        MESSAGE="Resize completed successfully."
    else
        MESSAGE="No need to resize partition."
    fi
fi

systemd-notify --status=$MESSAGE --ready
echo "done."
