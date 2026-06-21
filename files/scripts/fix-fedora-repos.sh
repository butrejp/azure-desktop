#!/bin/bash
set -euo pipefail

# --- 1. Disable zchunk globally ---
grep -q "^zchunk=" /etc/dnf/dnf.conf || echo "zchunk=False" >> /etc/dnf/dnf.conf

# --- 2. Fix repo files ---
for repo in /etc/yum.repos.d/fedora*.repo /etc/yum.repos.d/fedora-*.repo; do
    [ -f "$repo" ] || continue

    # Hardcode releasever to 43 (Azure Linux's os-release won't match Fedora)
    sed -i 's/\$releasever/43/g' "$repo"
    sed -i 's/\$basearch/x86_64/g' "$repo"

    # Disable metalink, use baseurl
    sed -i 's/^metalink/#metalink/g' "$repo"
    sed -i 's/^#baseurl/baseurl/g' "$repo"

    # Fix placeholder domains
    sed -i 's|download.example|dl.fedoraproject.org|g' "$repo"

    # Disable zchunk per-repo
    grep -q "^zchunk=" "$repo" || echo "zchunk=False" >> "$repo"
done

# --- 3. Nuke repos that are broken or unnecessary ---
# fedora-cisco-openh264 has no baseurl, only metalink, and we don't need H.264 codecs
rm -f /etc/yum.repos.d/fedora-cisco-openh264.repo

# These modular repos are deprecated and unnecessary
rm -f /etc/yum.repos.d/fedora-modular.repo 2>/dev/null || true
rm -f /etc/yum.repos.d/fedora-updates-modular.repo 2>/dev/null || true

# --- 4. Disable any remaining repo that lacks a valid source ---
for repo in /etc/yum.repos.d/fedora*.repo; do
    [ -f "$repo" ] || continue
    if ! grep -qE "^baseurl=" "$repo" && ! grep -qE "^metalink=" "$repo"; then
        sed -i 's/^enabled=.*/enabled=0/' "$repo"
        grep -q "^enabled=" "$repo" || echo "enabled=0" >> "$repo"
    fi
done

# --- 5. Aggressive cache clearing ---
rm -rf /var/cache/libdnf5/* /var/cache/libdnf5/.??* 2>/dev/null || true
rm -rf /var/cache/rpm-ostree/* /var/cache/rpm-ostree/.??* 2>/dev/null || true
dnf5 clean all

echo "=== dnf5 repolist after fix ==="
dnf5 repolist || true
