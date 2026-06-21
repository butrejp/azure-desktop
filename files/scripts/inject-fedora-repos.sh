#!/bin/bash
set -euo pipefail

# --- 1. Install Fedora repo/key RPMs directly ---
# Using dnf5 install <url> so deps are resolved properly
# (unlike rpm -Uvh which would need --nodeps on Azure Linux)

FEDORA_REPOS_URL="https://dl.fedoraproject.org/pub/fedora/linux/releases/43/Everything/x86_64/os/Packages/f/fedora-repos-43-1.noarch.rpm"
FEDORA_GPG_URL="https://dl.fedoraproject.org/pub/fedora/linux/releases/43/Everything/x86_64/os/Packages/f/fedora-gpg-keys-43-1.noarch.rpm"

# Skip fedora-release to avoid /etc/os-release conflicts with Azure Linux
dnf5 install -y "$FEDORA_REPOS_URL" "$FEDORA_GPG_URL"

# --- 2. Import GPG keys ---
for key in /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-43-*; do
    [ -f "$key" ] && rpm --import "$key" || true
done

# --- 3. Clean caches ---
dnf5 clean all
rm -rf /var/cache/libdnf5/* /var/cache/rpm-ostree/* 2>/dev/null || true
