#!/bin/sh

# Early initramfs init script:
# - Mounts pseudo filesystems
# - Parses kernel cmdline for root device
# - Detects NVMe format it and use it as "bitcoin" ext4 partition
# - Sets up IMA/EVM keys and loads IMA policy
# - Mounts the real rootfs and switches to /sbin/init
#
# SPDX-License-Identifier: MIT
# Copyright 2026 Embetrix Embedded Systems Solutions <ayoub.zaki@embetrix.com>

export PATH=$PATH:/sbin:/usr/sbin

ROOT_MNT="/tmp/rootfs"
BOOT_MNT="/boot"
DATA_MNT="/var/data"
BITCOIN_MNT="/var/bitcoin"
WALLETS_MNT="/var/wallets"
BACKUPS_MNT="/var/backups"

ROOT_DEV=""
NVME_DEV=""
BITCOIN_DEV=""

OPT_ROOT="ro,noatime"
OPT_PART="noexec,nodev,nosuid,noatime"

IMA_POLICY="/etc/ima/ima-policy"
IMA_X509="/etc/keys/x509_ima.der"
EVM_X509="/etc/keys/x509_evm.der"

TIMEOUT=40

# Init
INIT="/sbin/init"

mount_pseudo_fs() {

	mount -t devtmpfs none /dev
	mount -t tmpfs tmp /tmp
	mount -t proc proc /proc
	mount -t sysfs sysfs /sys
	mount -t securityfs -o $OPT_PART securityfs /sys/kernel/security
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

setup_ima_evm() {
	# Import IMA/EVM X509
	if [ ! -f "$IMA_X509" ] && [ ! -f "$EVM_X509" ]; then
		error_exit "IMA/EVM X509 certificates not found!"
	fi

	ima_id=$(keyctl newring _ima @u)
	evmctl import "$IMA_X509" $ima_id

	evm_id=$(keyctl newring _evm @u)
	evmctl import "$EVM_X509" $evm_id

	# Load IMA policy
	if [ ! -f "$IMA_POLICY" ]; then
		error_exit "IMA policy not found!"
	fi

	# Get root filesystem UUID
	FSUUID=$(blkid $ROOT_DEV -s UUID -o value)
	if [ -z "$FSUUID" ]; then
		error_exit "cannot get filesystem UUID for $ROOT_DEV"
	fi

	# Replace placeholder in IMA policy before loading it
	sed "s|__FSUUID__|$FSUUID|g" "$IMA_POLICY" > /sys/kernel/security/integrity/ima/policy \
		|| error_exit "cannot load IMA policy"

	# Enable EVM in signature verification mode only
	echo "0x80000002" > /sys/kernel/security/integrity/evm/evm
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

setup_nvme() {

	for d in /dev/nvme*n1; do
		[ -b "$d" ] || continue
		NVME_DEV="$d"
		break
	done

	if [ -z "$NVME_DEV" ]; then
		return 0
	fi

	echo "NVMe device detected: $NVME_DEV"

	# Ensure the NVMe disk is a single GPT partition we can use for bitcoin
	PART_COUNT=$(sgdisk -p "$NVME_DEV" 2>/dev/null | grep "^ *[0-9]" | wc -l)
	NVME_PART="${NVME_DEV}p1"
	NVME_LABEL=$(blkid -s PARTLABEL -o value "$NVME_PART" 2>/dev/null || true)

	if [ "$PART_COUNT" -ne 1 ] || [ "$NVME_LABEL" != "bitcoin" ]; then
		echo "Preparing $NVME_DEV as a single 'bitcoin' partition (this may erase existing data)..."
		sgdisk --zap-all "$NVME_DEV" || error_exit "Failed to wipe partition table on $NVME_DEV"
		sgdisk -n 1:0:0 -c 1:bitcoin "$NVME_DEV" || error_exit "Failed to create bitcoin partition on $NVME_DEV"
		partprobe "$NVME_DEV" 2>/dev/null || true
		sleep 1
	fi

	FSTYPE=$(blkid -s TYPE -o value "$NVME_PART" 2>/dev/null || true)
	if [ "$FSTYPE" != "ext4" ]; then
		echo "Formatting $NVME_PART as ext4 (label: bitcoin) (was: ${FSTYPE:-none})..."
		mkfs.ext4 -F -L bitcoin "$NVME_PART" || error_exit "Failed to format $NVME_PART"
	fi

	BITCOIN_DEV="$NVME_PART"
}

# If an NVMe disk is present, use it for the bitcoin volume
setup_nvme

# Setup IMA/EVM
setup_ima_evm

# Mount root filesystem
mkdir -p $ROOT_MNT
mount -o $OPT_ROOT $ROOT_DEV $ROOT_MNT   || error_exit "cannot mount root filesystem"

# Mount data volume
mount -o $OPT_PART -L data $ROOT_MNT$DATA_MNT || error_exit "cannot mount $DATA_MNT"
if [ -n "$BITCOIN_DEV" ]; then
	mount -o $OPT_PART "$BITCOIN_DEV" $ROOT_MNT$BITCOIN_MNT  || error_exit "cannot mount $BITCOIN_MNT from $BITCOIN_DEV"
else
	mount -o $OPT_PART -L bitcoin  $ROOT_MNT$BITCOIN_MNT  || error_exit "cannot mount $BITCOIN_MNT"
fi
mount -o $OPT_PART -L wallets  $ROOT_MNT$WALLETS_MNT  || error_exit "cannot mount $WALLETS_MNT"
mount -o $OPT_PART -L backups  $ROOT_MNT$BACKUPS_MNT  || error_exit "cannot mount $BACKUPS_MNT"
mount -L boot  $ROOT_MNT$BOOT_MNT  || error_exit "cannot mount $BOOT_MNT"

# Switch to real root
echo "Switch to real root..."
exec switch_root $ROOT_MNT $INIT || error_exit "cannot switch_root to real root"
