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

# Microsoft Edge repo
cat > /etc/yum.repos.d/microsoft-edge.repo << 'EOF'
[microsoft-edge]
name=microsoft-edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# PowerShell repo — Microsoft uses RHEL/CentOS repos for PowerShell on Fedora
cat > /etc/yum.repos.d/powershell.repo << 'EOF'
[powershell]
name=PowerShell
baseurl=https://packages.microsoft.com/yumrepos/microsoft-rhel9-prod
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Import Microsoft GPG key
rpm --import https://packages.microsoft.com/keys/microsoft.asc