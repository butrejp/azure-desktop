#!/bin/bash
set -euo pipefail

echo "Configuring dracut for OSTree..."

# Fedora uses 98ostree, not 50ostree
mkdir -p /etc/dracut.conf.d
cat > /etc/dracut.conf.d/99-ostree.conf << 'EOF'
force_add_dracutmodules+=" ostree bootc "
add_dracutmodules+=" ostree bootc "
EOF

chmod 644 /etc/dracut.conf.d/99-ostree.conf

# Persistent marker for dracut module detection
mkdir -p /usr/lib
touch /usr/lib/ostree-booted

echo "Dracut config written:"
cat /etc/dracut.conf.d/99-ostree.conf
