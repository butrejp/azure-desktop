#!/bin/bash
set -euo pipefail

# Find the latest installed kernel version
kver=$(ls /lib/modules | sort -V | tail -1)
echo "Regenerating initramfs for kernel: $kver"

# Ensure /boot exists and is writable
mkdir -p /boot

# Generate initramfs with ostree and bootc modules forced in
dracut --force --no-hostonly --add "ostree bootc" \
       --kver "$kver" \
       /boot/initramfs-${kver}.img "${kver}"

# Verify the ostree module made it in
if ! lsinitrd "/boot/initramfs-${kver}.img" | grep -q "usr/lib/dracut/modules.d/50ostree"; then
    echo "ERROR: 50ostree dracut module not found in generated initramfs"
    exit 1
fi

echo "Initramfs verified at /boot/initramfs-${kver}.img"
ls -la "/boot/initramfs-${kver}.img"
