#!/bin/bash
set -euo pipefail

# Azure Linux Base repo
cat > /etc/yum.repos.d/azurelinux.repo << 'EOF'
[azurelinux-base]
name=Azure Linux 4.0 - $basearch - Base
baseurl=https://packages.microsoft.com/azurelinux/4.0/beta/base/$basearch
enabled=1
countme=1
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-azurelinux-4.0-$basearch
skip_if_unavailable=False

[azurelinux-base-debuginfo]
name=Azure Linux 4.0 - $basearch - Base - Debug
baseurl=https://packages.microsoft.com/azurelinux/4.0/beta/base/debuginfo/$basearch
enabled=0
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-azurelinux-4.0-$basearch
skip_if_unavailable=True

[azurelinux-base-source]
name=Azure Linux 4.0 - Base - Source
baseurl=https://packages.microsoft.com/azurelinux/4.0/beta/base/srpms
enabled=0
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-azurelinux-4.0-$basearch
skip_if_unavailable=True
EOF

# Azure Linux Microsoft repo
cat > /etc/yum.repos.d/microsoft.repo << 'EOF'
[azurelinux-microsoft]
name=Azure Linux 4.0 - $basearch - Microsoft
baseurl=https://packages.microsoft.com/azurelinux/4.0/beta/microsoft/$basearch
enabled=1
countme=1
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-azurelinux-4.0-$basearch
skip_if_unavailable=False
EOF

# Import Azure Linux GPG key if not present
if [ ! -f /etc/pki/rpm-gpg/RPM-GPG-KEY-azurelinux-4.0-x86_64 ]; then
    mkdir -p /etc/pki/rpm-gpg
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor > /etc/pki/rpm-gpg/RPM-GPG-KEY-azurelinux-4.0-x86_64
fi