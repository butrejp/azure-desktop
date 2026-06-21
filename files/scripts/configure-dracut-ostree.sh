#!/bin/bash
set -euo pipefail

# Create persistent OSTree boot marker (required by dracut module check)
# /run/ostree-booted is volatile and won't survive into the OSTree commit
touch /usr/lib/ostree-booted

# Force dracut to include ostree and bootc modules regardless of check() result
mkdir -p /etc/dracut.conf.d

cat > /etc/dracut.conf.d/ostree.conf <<'EOF'
force_add_dracutmodules+=" ostree bootc "
install_items+=" /usr/lib/ostree/prepare-root.cfg /usr/lib/ostree-booted "
EOF

# Verify modules exist
for mod in 50ostree 51bootc; do
    if [ ! -d "/usr/lib/dracut/modules.d/$mod" ]; then
        echo "ERROR: $mod dracut module not found!" >&2
        ls -la /usr/lib/dracut/modules.d/ | grep -E "ostree|bootc" || true
        exit 1
    fi
    echo "Verified: /usr/lib/dracut/modules.d/$mod"
done

# Clean caches
dnf5 clean all
rm -rf /var/cache/libdnf5/* /var/cache/rpm-ostree/* 2>/dev/null || true
