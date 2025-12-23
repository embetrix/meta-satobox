#!/bin/sh

export PATH=$PATH:/sbin:/usr/sbin

ROOT_MNT="/tmp/rootfs"
DATA_MNT="/var/data"
BITCOIN_MNT="/var/bitcoin"
WALLETS_MNT="/var/wallets"
BACKUPS_MNT="/var/backups"
ROOT_DEV=""
OPT_ROOT="ro,noatime"
OPT_PART="noexec,nodev,nosuid,noatime"

TIMEOUT=40

# Init
INIT="/sbin/init"

mount_pseudo_fs() {

	mount -t devtmpfs none /dev
	mount -t tmpfs tmp /tmp
	mount -t proc proc /proc
	mount -t sysfs sysfs /sys

	# this is needed to make pipe work in shell
	ln -s /proc/self/fd /dev/fd
}

parse_cmdline() {

	#Parse kernel cmdline to extract base device path
	CMDLINE="$(cat /proc/cmdline)"
	echo "Kernel cmdline: $CMDLINE"
	for c in ${CMDLINE}; do
		if [ "${c:0:5}" == "root=" ]; then
			ROOT_DEV="${c:5}"
		fi
	done
}

error_exit() {

	echo "$1!"
	sleep 2
	reboot -f
}

wait_for_dev() {
	i=0
	while [ $i -lt $TIMEOUT ]; do
		if [ -b $1  ] ; then
				break;
		fi
		let i=i+1
		sleep 0.1
	done
	if [ $i -eq $TIMEOUT ]; then
		error_exit "Timeout waiting for $1"
	fi
}


echo "Starting Initramfs..."
mount_pseudo_fs
parse_cmdline

# Check root device
echo "Root device: $ROOT_DEV"
if [ "$ROOT_DEV" == "" ] || [ "$ROOT_DEV" == "/dev/nfs" ]; then
	error_exit "cannot get root device"
fi

wait_for_dev $ROOT_DEV

# Handle both mmcblkXpY and sdaY naming schemes
if echo "$ROOT_DEV" | grep -q 'p[0-9]$'; then
	# mmcblk or nvme device (has 'p' separator)
	DEVICE=${ROOT_DEV%p*}
else
	# Regular disk device like sda, sdb (no 'p' separator)
	DEVICE=${ROOT_DEV%[0-9]*}
fi

# Find the last partition number on the device
PART_NBR=$(sgdisk -p $DEVICE | grep "^ *[0-9]" | awk '{print $1}' | tail -1)

if [ -z "$PART_NBR" ]; then
	error_exit "Could not determine last partition number on $DEVICE"
fi

# Reconstruct PART with correct separator
case "$DEVICE" in
	*mmcblk*|*nvme*)
		PART="$DEVICE"p"$PART_NBR"
		;;
	*)
		PART="$DEVICE""$PART_NBR"
		;;
esac

echo "Found last partition: $PART (partition $PART_NBR on $DEVICE)"

LABEL=$(blkid -s PARTLABEL -o value $PART)
SECTORS=$(blockdev --getsz $PART)

if [ -z "$DEVICE" ] || [ -z "$PART" ] || [ -z "$PART_NBR" ]; then
	error_exit "Failed to identify partition details!"
fi

# Check if partition can be extended to maximum
echo "Checking if partition $PART can be extended..."
DEVICE_SECTORS=$(blockdev --getsz $DEVICE)
DEVICE_END=$((DEVICE_SECTORS - 1))

# Get partition end sector from sgdisk partition table
LAST_PART_END=$(sgdisk -p $DEVICE | grep "^ *$PART_NBR " | awk '{print int($3)}')

if [ -n "$LAST_PART_END" ] && [ $LAST_PART_END -lt $DEVICE_END ]; then
	echo "Partition sectors: $SECTORS"
	echo "Last partition end: $LAST_PART_END"
	echo "Device end: $DEVICE_END"
	echo "Partition has free space available. Resizing partition $PART to maximum..."
	sgdisk -d $PART_NBR -n $PART_NBR:0:0 -c $PART_NBR:$LABEL $DEVICE
	partprobe $DEVICE

	# Wait and force kernel to re-read partition table
	sleep 1
	blockdev --rereadpt $DEVICE 2>/dev/null || true
	sleep 1

	# Get new partition size after resize
	NEW_SECTORS=$(blockdev --getsz $PART)
	echo "Partition size after resize: $NEW_SECTORS sectors (was $SECTORS)"

	# Only proceed with filesystem resize if partition actually grew
	if [ $NEW_SECTORS -gt $SECTORS ]; then
		echo "Resizing filesystem..."
		resize2fs $PART
		echo "Filesystem resize completed successfully."
		sleep 2
		echo "Rebooting system to apply changes..."
		reboot -f
	else
		echo "Partition size did not change, no resize needed."
	fi
fi

# Mount root filesystem
mkdir -p $ROOT_MNT
mount -o $OPT_ROOT $ROOT_DEV $ROOT_MNT   || error_exit "cannot mount root filesystem"

# Mount data volume
mount -o $OPT_PART -L data     $ROOT_MNT$DATA_MNT     || error_exit "cannot mount $DATA_MNT"
mount -o $OPT_PART -L bitcoin  $ROOT_MNT$BITCOIN_MNT  || error_exit "cannot mount $BITCOIN_MNT"
mount -o $OPT_PART -L wallets  $ROOT_MNT$WALLETS_MNT  || error_exit "cannot mount $WALLETS_MNT"
mount -o $OPT_PART -L backups  $ROOT_MNT$BACKUPS_MNT  || error_exit "cannot mount $BACKUPS_MNT"

# Switch to real root
echo "Switch to real root..."
exec switch_root $ROOT_MNT $INIT || error_exit "cannot switch_root to real root"
