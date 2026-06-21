#!/bin/bash
set -euo pipefail

# Ensure dracut picks up the ostree module
mkdir -p /etc/dracut.conf.d

cat > /etc/dracut.conf.d/ostree.conf <<'EOF'
add_dracutmodules+=" ostree "
install_items+=" /usr/lib/ostree/prepare-root.cfg "
EOF

# Verify the ostree dracut module is present (Fedora uses 50ostree, not 98ostree)
OSTREE_MODULE=""
for mod in /usr/lib/dracut/modules.d/50ostree /usr/lib/dracut/modules.d/98ostree; do
    if [ -d "$mod" ]; then
        OSTREE_MODULE="$mod"
        break
    fi
done

if [ -z "$OSTREE_MODULE" ]; then
    echo "ERROR: ostree dracut module not found!" >&2
    echo "Checked: 50ostree, 98ostree" >&2
    ls -la /usr/lib/dracut/modules.d/ | grep -E "ostree|bootc" || true
    exit 1
fi

echo "ostree dracut module verified at: $OSTREE_MODULE"
ls -la "$OSTREE_MODULE/"

# Clean caches
dnf5 clean all
rm -rf /var/cache/libdnf5/* /var/cache/rpm-ostree/* 2>/dev/null || true
