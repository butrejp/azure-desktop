#!/bin/bash
set -euo pipefail

# Fix /root symlink for dracut
if [ -L /root ] && [ ! -e /root ]; then
    rm -f /root
    mkdir -p /root
    chmod 700 /root
fi

# Should now be exactly one kernel
kver=$(ls /lib/modules | sort -V | tail -1)
echo "Kernel version: $kver"

# Verify it's the one we want
echo "=== Installed kernels ==="
ls /lib/modules/

echo "Generating initramfs..."
dracut --force --no-hostonly --add "ostree bootc" \
       --kver "$kver" \
       /usr/lib/modules/${kver}/initramfs.img "${kver}"

ls -la "/usr/lib/modules/${kver}/initramfs.img"
