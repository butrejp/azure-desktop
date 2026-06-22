#!/usr/bin/env bash
set -ouex pipefail

cat > /usr/lib/os-release << 'EOF'
NAME="Azure Linux"
VERSION="4.0 (Container Image Beta)"
RELEASE_TYPE=development
ID=azurelinux
ID_LIKE=fedora
VERSION_ID=43
VERSION_CODENAME=""
PRETTY_NAME="Azure Linux 4.0 (Container Image Beta)"
ANSI_COLOR="0;38;2;60;110;180"
LOGO=azurelinux-logo-icon
CPE_NAME="cpe:2.3:o:microsoft:azure_linux:4.0:*:*:*:*:*:*:*"
DEFAULT_HOSTNAME="azurelinux"
HOME_URL="https://aka.ms/azurelinux"
DOCUMENTATION_URL="https://aka.ms/azurelinux"
SUPPORT_URL="https://aka.ms/azurelinux"
BUG_REPORT_URL="https://aka.ms/azurelinux"
VARIANT="Container Image"
VARIANT_ID=container
EOF

# Ensure /etc/os-release symlinks to the immutable one
ln -sf ../usr/lib/os-release /etc/os-release