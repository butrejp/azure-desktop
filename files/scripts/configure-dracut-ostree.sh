#!/bin/bash
set -euo pipefail

# Ensure dracut picks up the ostree module
mkdir -p /etc/dracut.conf.d

cat > /etc/dracut.conf.d/ostree.conf <<'EOF'
add_dracutmodules+=" ostree "
install_items+=" /usr/lib/ostree/prepare-root.cfg "
EOF

# Verify the 98ostree module is present
if [ ! -d /usr/lib/dracut/modules.d/98ostree ]; then
    echo "ERROR: 98ostree dracut module not found!" >&2
    echo "Fedora ostree package may not have installed correctly." >&2
    ls -la /usr/lib/dracut/modules.d/ || true
    exit 1
fi

echo "98ostree dracut module verified at:"
ls -la /usr/lib/dracut/modules.d/98ostree/

# Clean caches
dnf5 clean all
rm -rf /var/cache/libdnf5/* /var/cache/rpm-ostree/* 2>/dev/null || true
