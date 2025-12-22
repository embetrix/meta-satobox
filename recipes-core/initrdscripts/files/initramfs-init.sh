#!/bin/sh -x

export PATH=$PATH:/sbin:/usr/sbin

ROOT_MNT="/tmp/rootfs"
DATA_MNT="/var/data"
BITCOIN_MNT="/var/bitcoin"
WALLETS_MNT="/var/wallets"
BACKUPS_MNT="/var/backups"
ROOT_DEV=""
OPT_ROOT="ro,noatime"
OPT_PART="noexec,nodev,nosuid,noatime"

# 4GB in sectors (assuming 512-byte sectors)
THRESHOLD=8388608
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
	sleep 5
	sh
	#reboot -f
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

mount_pseudo_fs

echo "Starting Initramfs..."
parse_cmdline

# Check root device
echo "Root device: $ROOT_DEV"
if [ "$ROOT_DEV" == "" ] || [ "$ROOT_DEV" == "/dev/nfs" ]; then
	error_exit "cannot get root device"
fi

wait_for_dev $ROOT_DEV

# Resizes the last GPT partition to the max available size and formats it with ext4 if below THRESHOLD.
DEVICE=${ROOT_DEV%p*}
PART="/dev/$(lsblk -rno NAME $DEVICE | grep -E '[0-9]+$' | tail -n 1)"
PART_NBR=${PART##*p}
LABEL=$(blkid -s PARTLABEL -o value $PART)
SECTORS=$(blockdev --getsz $PART)
MIN_SEC=$THRESHOLD

if [ -z "$DEVICE" ] || [ -z "$PART" ] || [ -z "$PART_NBR" ] || [ -z "$LABEL" ]; then
	error_exit "No device found with label $LABEL!"
fi

if [ $SECTORS -lt $MIN_SEC ]; then
	echo "Resizing partition $PART"
	sgdisk -d $PART_NBR -n $PART_NBR:0:0 -c $PART_NBR:$LABEL $DEVICE
	hdparm -z $DEVICE
	mkfs.ext4 -F $PART -L $LABEL
	echo "Resize completed successfully, Rebooting system..."
	sync
	sleep 5
	reboot -f
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
