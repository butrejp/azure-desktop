#!/bin/bash
set -euo pipefail

# VS Code repo
cat > /etc/yum.repos.d/vscode.repo << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Microsoft production repo (Fedora 43) for PowerShell, Edge, etc.
cat > /etc/yum.repos.d/microsoft-prod.repo << 'EOF'
[packages-microsoft-com-prod]
name=Microsoft Production
baseurl=https://packages.microsoft.com/fedora/43/prod/
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Import Microsoft GPG key
rpm --import https://packages.microsoft.com/keys/microsoft.asc