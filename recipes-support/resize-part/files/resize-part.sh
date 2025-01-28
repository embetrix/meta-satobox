#!/bin/sh
# Copyright 2025  Embetrix Embedded Systems Solutions, ayoub.zaki@embetrix.com
#

LABEL="bitcoin"
DEVICE=$(blkid --label $LABEL)
if [ -z "$DEVICE" ]; then
    echo "No device found with label $LABEL"
fi
systemd-notify --status="Resize completed successfully." --ready
echo "done"