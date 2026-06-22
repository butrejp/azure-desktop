#!/bin/bash
set -euo pipefail

trap 'echo "ERROR at line $LINENO: exit code $?" >&2' ERR

echo "=== Pre-creating system users for Fedora packages ==="

ensure_passwd_entry() {
    local user="$1" uid="$2" gid="$3" gecos="$4" home="$5" shell="$6"
    local entry="$user:x:$uid:$gid:$gecos:$home:$shell"
    local shadow="$user:!!:19842:0:99999:7:::"

    for db in /etc/passwd /usr/lib/passwd; do
        mkdir -p "$(dirname "$db")"
        touch "$db"
        if ! grep -q "^$user:" "$db" 2>/dev/null; then
            echo "$entry" >> "$db"
            echo "Added $user to $db"
        fi
    done

    for db in /etc/shadow /usr/lib/shadow; do
        mkdir -p "$(dirname "$db")"
        touch "$db"
        if ! grep -q "^$user:" "$db" 2>/dev/null; then
            echo "$shadow" >> "$db"
        fi
        chmod 000 "$db"
    done
}

ensure_group_entry() {
    local group="$1" gid="$2"
    local entry="$group:x:$gid:"

    for db in /etc/group /usr/lib/group; do
        mkdir -p "$(dirname "$db")"
        touch "$db"
        if ! grep -q "^$group:" "$db" 2>/dev/null; then
            echo "$entry" >> "$db"
            echo "Added $group to $db"
        fi
    done

    for db in /etc/gshadow /usr/lib/gshadow; do
        mkdir -p "$(dirname "$db")"
        touch "$db"
        if ! grep -q "^$group:" "$db" 2>/dev/null; then
            echo "$group:!!::" >> "$db"
        fi
        chmod 000 "$db"
    done
}

# --- systemd users ---
ensure_group_entry systemd-network 192
ensure_passwd_entry systemd-network 192 192 "systemd Network Management" /run/systemd/netif /usr/sbin/nologin

ensure_group_entry systemd-resolve 193
ensure_passwd_entry systemd-resolve 193 193 "systemd Resolver" /run/systemd/resolve /usr/sbin/nologin

ensure_group_entry systemd-timesync 194
ensure_passwd_entry systemd-timesync 194 194 "systemd Time Synchronization" /run/systemd/timesync /usr/sbin/nologin

# --- polkit ---
ensure_group_entry polkitd 998
ensure_passwd_entry polkitd 998 998 "User for polkitd" / /usr/sbin/nologin

# --- D-Bus ---
ensure_group_entry dbus 81
ensure_passwd_entry dbus 81 81 "System message bus" / /usr/sbin/nologin
ensure_group_entry messagebus 81
ensure_passwd_entry messagebus 81 81 "System message bus" / /usr/sbin/nologin

# --- Desktop/GNOME users ---
ensure_group_entry rtkit 172
ensure_passwd_entry rtkit 172 172 "RealtimeKit" /proc /usr/sbin/nologin

ensure_group_entry geoclue 992
ensure_passwd_entry geoclue 992 992 "Geolocation service" /var/lib/geoclue /usr/sbin/nologin

ensure_group_entry pipewire 996
ensure_passwd_entry pipewire 996 996 "PipeWire System Daemon" /var/run/pipewire /usr/sbin/nologin

ensure_group_entry colord 997
ensure_passwd_entry colord 997 997 "Color management daemon" /var/lib/colord /usr/sbin/nologin

ensure_group_entry flatpak 994
ensure_passwd_entry flatpak 994 994 "Flatpak system helper" / /usr/sbin/nologin

ensure_group_entry gdm 42
ensure_passwd_entry gdm 42 42 "GNOME Display Manager" /var/lib/gdm /sbin/nologin

# --- Pre-create runtime directories ---
mkdir -p /var/lib/systemd/network /var/lib/systemd/resolved /var/lib/polkit-1
mkdir -p /var/lib/geoclue /var/lib/colord /var/lib/gdm
mkdir -p /var/run/pipewire /run/systemd/netif /run/systemd/resolve /run/systemd/timesync

# --- Force systemd-sysusers to run on every boot by removing conditions ---
mkdir -p /usr/lib/systemd/system/systemd-sysusers.service.d
cat > /usr/lib/systemd/system/systemd-sysusers.service.d/override.conf << 'EOF'
[Unit]
ConditionNeedsUpdate=
ConditionCredential=
EOF

# --- Also force it via a one-shot first-boot service ---
mkdir -p /usr/lib/systemd/system
cat > /usr/lib/systemd/system/azure-firstboot-users.service << 'EOF'
[Unit]
Description=Ensure system users exist on first boot
DefaultDependencies=no
Before=sysinit.target
After=systemd-remount-fs.service

[Service]
Type=oneshot
ExecStart=/usr/bin/systemd-sysusers
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
EOF

# --- Enable the first-boot service ---
mkdir -p /etc/systemd/system/sysinit.target.wants
ln -sf /usr/lib/systemd/system/azure-firstboot-users.service /etc/systemd/system/sysinit.target.wants/azure-firstboot-users.service

# --- Run systemd-sysusers now during build ---
if command -v systemd-sysusers >/dev/null 2>&1; then
    echo "Running systemd-sysusers now..."
    systemd-sysusers --root=/
fi

# --- Verify ---
echo "=== /etc/passwd ==="
cat /etc/passwd
echo ""
echo "=== /etc/group ==="
cat /etc/group

echo "=== Done creating system users ==="
exit 0