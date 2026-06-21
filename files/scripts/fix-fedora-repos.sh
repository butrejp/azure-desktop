#!/bin/bash
set -euo pipefail

# --- 1. Disable zchunk globally ---
grep -q "^zchunk=" /etc/dnf/dnf.conf || echo "zchunk=False" >> /etc/dnf/dnf.conf

# --- 2. Fix repo files ---
for repo in /etc/yum.repos.d/fedora*.repo /etc/yum.repos.d/fedora-*.repo; do
    [ -f "$repo" ] || continue

    sed -i 's/\$releasever/43/g' "$repo"
    sed -i 's/\$basearch/x86_64/g' "$repo"
    sed -i 's/^metalink/#metalink/g' "$repo"
    sed -i 's/^#baseurl/baseurl/g' "$repo"
    sed -i 's|download.example|dl.fedoraproject.org|g' "$repo"

    # Disable zchunk per-repo
    grep -q "^zchunk=" "$repo" || echo "zchunk=False" >> "$repo"
done

# --- 3. Disable problematic repos ---
dnf5 config-manager setopt fedora-cisco-openh264.enabled=0 2>/dev/null || true
dnf5 config-manager setopt fedora-modular.enabled=0 2>/dev/null || true
dnf5 config-manager setopt fedora-updates-modular.enabled=0 2>/dev/null || true

# --- 4. Force cache rebuild ---
rm -rf /var/cache/libdnf5/* /var/cache/libdnf5/.??* 2>/dev/null || true
rm -rf /var/cache/rpm-ostree/* /var/cache/rpm-ostree/.??* 2>/dev/null || true
dnf5 clean all
dnf5 makecache 2>/dev/null || true

echo "=== dnf5 repolist after fix ==="
dnf5 repolist || true
