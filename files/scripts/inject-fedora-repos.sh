#!/bin/bash
set -euo pipefail

# --- 1. Download Fedora repo/key RPMs to temp ---
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

FEDORA_REPOS_URL="https://dl.fedoraproject.org/pub/fedora/linux/releases/43/Everything/x86_64/os/Packages/f/fedora-repos-43-1.noarch.rpm"
FEDORA_GPG_URL="https://dl.fedoraproject.org/pub/fedora/linux/releases/43/Everything/x86_64/os/Packages/f/fedora-gpg-keys-43-1.noarch.rpm"

curl -fLO --retry 3 "$FEDORA_REPOS_URL"
curl -fLO --retry 3 "$FEDORA_GPG_URL"

# --- 2. Extract .repo files from fedora-repos RPM ---
# rpm2cpio + cpio extracts contents without installing dependencies
rpm2cpio fedora-repos-43-1.noarch.rpm | cpio -idmv -D / ./etc/yum.repos.d/

# --- 3. Extract GPG keys from fedora-gpg-keys RPM ---
rpm2cpio fedora-gpg-keys-43-1.noarch.rpm | cpio -idmv -D / ./etc/pki/rpm-gpg/

# --- 4. Import GPG keys ---
for key in /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-43-*; do
    [ -f "$key" ] && rpm --import "$key" || true
done

# --- 5. Cleanup ---
cd /
rm -rf "$TMPDIR"

# --- 6. Disable zchunk globally ---
grep -q "^zchunk=" /etc/dnf/dnf.conf || echo "zchunk=False" >> /etc/dnf/dnf.conf

# --- 7. Clean caches ---
dnf5 clean all
rm -rf /var/cache/libdnf5/* /var/cache/rpm-ostree/* 2>/dev/null || true

echo "Fedora 43 repos and GPG keys injected successfully."
