#!/bin/bash
set -euo pipefail

kver=$(ls /lib/modules | sort -V | tail -1)
echo "Kernel version: $kver"

echo "=== Dracut modules available ==="
dracut --list-modules --kver "$kver" | grep -i ostree || echo "No ostree module found"

echo "=== Files on disk ==="
find /usr/lib/dracut/modules.d -maxdepth 1 \( -name "*ostree*" -o -name "*bootc*" \) || echo "No ostree/bootc dirs"

echo "=== Dracut config ==="
cat /etc/dracut.conf.d/99-ostree.conf 2>/dev/null || echo "Config missing"

# CRITICAL: Write initramfs to /usr/lib/modules/$kver/initramfs.img
# rpm-ostree/bootc picks it up from here during deployment
echo "Generating initramfs to /usr/lib/modules/$kver/initramfs.img..."
dracut --force --no-hostonly --add "ostree bootc" \
       --kver "$kver" \
       /usr/lib/modules/${kver}/initramfs.img "${kver}"

echo "=== Initramfs contents (ostree-related) ==="
lsinitrd "/usr/lib/modules/${kver}/initramfs.img" | grep -i "ostree\|bootc\|prepare-root" || true

if lsinitrd "/usr/lib/modules/${kver}/initramfs.img" | grep -q "ostree-prepare-root"; then
    echo "SUCCESS: ostree-prepare-root found in initramfs"
else
    echo "WARNING: ostree-prepare-root not found in initramfs"
fi

ls -la "/usr/lib/modules/${kver}/initramfs.img"
