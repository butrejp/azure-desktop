#!/bin/bash
set -euo pipefail

# Fix /root symlink for dracut — /var/roothome doesn't exist during build
if [ -L /root ] && [ ! -e /root ]; then
    rm -f /root
    mkdir -p /root
    chmod 700 /root
    echo "Fixed /root for dracut"
fi

# Should be exactly one kernel now
kver=$(ls /lib/modules | sort -V | tail -1)
echo "Kernel version: $kver"

echo "=== Installed kernels ==="
ls /lib/modules/

echo "=== Dracut modules available ==="
dracut --list-modules --kver "$kver" | grep -i ostree || echo "No ostree module found"

echo "=== Files on disk ==="
find /usr/lib/dracut/modules.d -maxdepth 1 \( -name "*ostree*" -o -name "*bootc*" \) || echo "No ostree/bootc dirs"

echo "=== Dracut config ==="
cat /etc/dracut.conf.d/99-ostree.conf 2>/dev/null || echo "Config missing"

# Generate initramfs to the path rpm-ostree expects
echo "Generating initramfs to /usr/lib/modules/$kver/initramfs.img..."
dracut --force --no-hostonly --add "ostree bootc" \
       --kver "$kver" \
       /usr/lib/modules/${kver}/initramfs.img "${kver}"

echo "=== Initramfs contents (ostree-related) ==="
lsinitrd "/usr/lib/modules/${kver}/initramfs.img" | grep -i "ostree\|bootc\|prepare-root" || true

# Verify ostree-prepare-root binary is present
if lsinitrd "/usr/lib/modules/${kver}/initramfs.img" | grep -q "ostree-prepare-root"; then
    echo "SUCCESS: ostree-prepare-root found in initramfs"
else
    echo "WARNING: ostree-prepare-root not found in initramfs"
fi

ls -la "/usr/lib/modules/${kver}/initramfs.img"
