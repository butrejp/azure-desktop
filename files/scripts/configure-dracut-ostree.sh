#!/bin/bash
set -euo pipefail

echo "Configuring dracut for OSTree..."

# Ensure /sysroot exists on host so dracut can reference it
mkdir -p /sysroot

# Custom dracut module: guarantees /sysroot directory is in the initramfs
mkdir -p /usr/lib/dracut/modules.d/99sysroot-fix
cat > /usr/lib/dracut/modules.d/99sysroot-fix/module-setup.sh << 'EOF'
#!/bin/bash
check() { return 0; }
depends() { return 0; }
install() {
    inst_dir /sysroot
}
EOF
chmod +x /usr/lib/dracut/modules.d/99sysroot-fix/module-setup.sh

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