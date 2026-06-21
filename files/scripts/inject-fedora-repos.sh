#!/bin/bash
set -euo pipefail

TMPDIR=$(mktemp -d)
cd "$TMPDIR"

FEDORA_REPOS_URL="https://dl.fedoraproject.org/pub/fedora/linux/releases/43/Everything/x86_64/os/Packages/f/fedora-repos-43-1.noarch.rpm"
FEDORA_GPG_URL="https://dl.fedoraproject.org/pub/fedora/linux/releases/43/Everything/x86_64/os/Packages/f/fedora-gpg-keys-43-1.noarch.rpm"

curl -fLO --retry 3 "$FEDORA_REPOS_URL"
curl -fLO --retry 3 "$FEDORA_GPG_URL"

# --- Extract to temp dir first, then copy (more robust than -D + pattern) ---
mkdir -p /tmp/fedora-extract
cd /tmp/fedora-extract

rpm2cpio "$TMPDIR/fedora-repos-43-1.noarch.rpm" | cpio -idmv
rpm2cpio "$TMPDIR/fedora-gpg-keys-43-1.noarch.rpm" | cpio -idmv

# Copy repo files and GPG keys to system
if [ -d etc/yum.repos.d ]; then
    cp -v etc/yum.repos.d/* /etc/yum.repos.d/
fi
if [ -d etc/pki/rpm-gpg ]; then
    cp -v etc/pki/rpm-gpg/* /etc/pki/rpm-gpg/
fi

# --- Import GPG keys ---
for key in /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-43-*; do
    [ -f "$key" ] && rpm --import "$key" || true
done

# --- Aggressive cache clearing (persistent mounts can poison the cache) ---
rm -rf /var/cache/libdnf5/* /var/cache/libdnf5/.??* 2>/dev/null || true
rm -rf /var/cache/rpm-ostree/* /var/cache/rpm-ostree/.??* 2>/dev/null || true
dnf5 clean all

# --- Debug: verify repos are visible to dnf5 ---
echo "=== /etc/yum.repos.d/ contents ==="
ls -la /etc/yum.repos.d/ || true

echo "=== dnf5 repolist ==="
dnf5 repolist || true

echo "=== dnf5 repo info fedora ==="
dnf5 repoinfo fedora 2>/dev/null || true

# Cleanup
rm -rf "$TMPDIR" /tmp/fedora-extract
