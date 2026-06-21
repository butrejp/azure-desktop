#!/bin/bash
set -euo pipefail

kver=$(ls /lib/modules | sort -V | tail -1)
echo "Kernel version: $kver"

echo "=== Dracut modules available ==="
dracut --list-modules | grep -i ostree || echo "No ostree module found"

echo "=== Files on disk ==="
find /usr/lib/dracut/modules.d -maxdepth 1 -name "*ostree*" -o -name "*bootc*" || echo "No ostree/bootc dirs"

echo "=== Dracut config ==="
cat /etc/dracut.conf.d/99-ostree.conf 2>/dev/null || echo "Config missing"

echo "Generating initramfs..."
dracut --force --no-hostonly --add "ostree bootc" \
       --kver "$kver" \
       /boot/initramfs-${kver}.img "${kver}"

echo "=== Initramfs contents (ostree-related) ==="
lsinitrd "/boot/initramfs-${kver}.img" | grep -i "ostree\|bootc\|prepare-root" || true

# Check for prepare-root binary (the actual pivot tool)
if lsinitrd "/boot/initramfs-${kver}.img" | grep -q "prepare-root"; then
    echo "SUCCESS: prepare-root found in initramfs"
else
    echo "WARNING: prepare-root not found in initramfs"
fi

ls -la "/boot/initramfs-${kver}.img"
