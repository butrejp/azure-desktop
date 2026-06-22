#!/bin/bash
set -uo pipefail
# Note: NO 'set -e' — we handle errors manually to avoid killing the build

echo "=== Pre-creating system users for Fedora packages ==="

# Helper: append to passwd/shadow/group/gshadow
ensure_passwd_entry() {
    local user="$1" uid="$2" gid="$3" gecos="$4" home="$5" shell="$6"
    local entry="$user:x:$uid:$gid:$gecos:$home:$shell"
    local shadow="$user:!!:19842:0:99999:7:::"

    for db in /etc/passwd /usr/lib/passwd; do
        mkdir -p "$(dirname "$db")" 2>/dev/null || true
        touch "$db" 2>/dev/null || true
        if ! grep -q "^$user:" "$db" 2>/dev/null; then
            echo "$entry" >> "$db" 2>/dev/null && echo "Added $user to $db" || echo "WARN: could not write $user to $db"
        fi
    done

    for db in /etc/shadow /usr/lib/shadow; do
        mkdir -p "$(dirname "$db")" 2>/dev/null || true
        touch "$db" 2>/dev/null || true
        if ! grep -q "^$user:" "$db" 2>/dev/null; then
            echo "$shadow" >> "$db" 2>/dev/null || true
        fi
        chmod 000 "$db" 2>/dev/null || true
    done
}

ensure_group_entry() {
    local group="$1" gid="$2"
    local entry="$group:x:$gid:"

    for db in /etc/group /usr/lib/group; do
        mkdir -p "$(dirname "$db")" 2>/dev/null || true
        touch "$db" 2>/dev/null || true
        if ! grep -q "^$group:" "$db" 2>/dev/null; then
            echo "$entry" >> "$db" 2>/dev/null && echo "Added $group to $db" || echo "WARN: could not write $group to $db"
        fi
    done

    for db in /etc/gshadow /usr/lib/gshadow; do
        mkdir -p "$(dirname "$db")" 2>/dev/null || true
        touch "$db" 2>/dev/null || true
        if ! grep -q "^$group:" "$db" 2>/dev/null; then
            echo "$group:!!::" >> "$db" 2>/dev/null || true
        fi
        chmod 000 "$db" 2>/dev/null || true
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

# --- Drop sysusers.d files as fallback ---
mkdir -p /usr/lib/sysusers.d 2>/dev/null || true
cat > /usr/lib/sysusers.d/99-azure-desktop.conf << 'EOF' 2>/dev/null || true
u systemd-network 192 "systemd Network Management" /run/systemd/netif
u systemd-resolve 193 "systemd Resolver" /run/systemd/resolve
u systemd-timesync 194 "systemd Time Synchronization" /run/systemd/timesync
u polkitd 998 "User for polkitd" /
u dbus 81 "System message bus" /
u rtkit 172 "RealtimeKit" /proc
u geoclue 992 "Geolocation service" /var/lib/geoclue
u pipewire 996 "PipeWire System Daemon" /var/run/pipewire
u colord 997 "Color management daemon" /var/lib/colord
u flatpak 994 "Flatpak system helper" /
u gdm 42 "GNOME Display Manager" /var/lib/gdm
EOF

# --- Force systemd-sysusers to re-run on next boot ---
touch /etc/.needs-update 2>/dev/null || true

# --- Try running systemd-sysusers, but don't fail if it errors ---
if command -v systemd-sysusers >/dev/null 2>&1; then
    echo "Running systemd-sysusers now..."
    systemd-sysusers --root=/ 2>/dev/null || echo "WARN: systemd-sysusers failed, continuing anyway"
fi

# --- Pre-create runtime directories ---
mkdir -p /var/lib/systemd/network /var/lib/systemd/resolved /var/lib/polkit-1 2>/dev/null || true
mkdir -p /var/lib/geoclue /var/lib/colord /var/lib/gdm 2>/dev/null || true
mkdir -p /var/run/pipewire /run/systemd/netif /run/systemd/resolve /run/systemd/timesync 2>/dev/null || true

# --- Verify ---
echo "=== /etc/passwd ==="
cat /etc/passwd 2>/dev/null || echo "cannot read /etc/passwd"
echo ""
echo "=== /etc/group ==="
cat /etc/group 2>/dev/null || echo "cannot read /etc/group"
echo ""
echo "=== /usr/lib/passwd ==="
cat /usr/lib/passwd 2>/dev/null || echo "not present"
echo ""
echo "=== /usr/lib/group ==="
cat /usr/lib/group 2>/dev/null || echo "not present"

echo "=== Done creating system users ==="
exit 0