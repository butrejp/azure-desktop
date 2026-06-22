#!/bin/bash
set -euo pipefail

echo "=== Installing Fedora @core group ==="

dnf5 group install core --allowerasing -y \
    --exclude=selinux-policy-targeted \
    --exclude=selinux-policy \
    --exclude=policycoreutils \
    --exclude=checkpolicy \
    --exclude=selinux-policy-minimum \
    --exclude=selinux-policy-mls

echo "=== Fedora @core installed ==="

# Verify key users now exist
echo "=== Verifying system users ==="
getent passwd systemd-network || echo "WARN: systemd-network missing"
getent passwd polkitd || echo "WARN: polkitd missing"
getent passwd gdm || echo "WARN: gdm missing"
getent passwd dbus || echo "WARN: dbus missing"

echo "=== /etc/nsswitch.conf ==="
cat /etc/nsswitch.conf | grep -E "passwd|group"

mkdir -p /etc/selinux
cat > /etc/selinux/config << 'EOF'
SELINUX=disabled
SELINUXTYPE=targeted
EOF