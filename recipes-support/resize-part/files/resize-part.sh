#!/bin/sh
# Copyright 2025  Embetrix Embedded Systems Solutions, ayoub.zaki@embetrix.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Resizes the last GPT partition to the max available size and formats it with ext4 if below THRESHOLD.
THRESHOLD=8388608   # 4GB in sectors (assuming 512-byte sectors)

RDEV=$(rdev | awk '{print $1}')
DEVICE=${RDEV%p*}
PART="/dev/$(lsblk -rno NAME $DEVICE | grep -E '[0-9]+$' | tail -n 1)"
PART_NBR=${PART##*p}
LABEL=$(blkid -s PARTLABEL -o value $PART)
SECTORS=$(blockdev --getsz $PART)
MIN_SEC=$THRESHOLD
MESSAGE=""

if [ -z "$DEVICE" ] || [ -z "$PART" ] || [ -z "$PART_NBR" ] || [ -z "$LABEL" ]; then
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
