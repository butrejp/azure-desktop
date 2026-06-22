#!/bin/bash
set -euo pipefail

# Create system groups and users that Fedora packages expect but Azure Linux lacks.
# These are typically created by RPM %pre scripts, which may not run correctly
# in a container/OSTree build environment.

# Helper: create group if missing, then user if missing
ensure_user() {
    local user="$1"
    local uid="$2"
    local group="$3"
    local gid="$4"
    local gecos="${5:-$user}"
    local home="${6:-/}"
    local shell="${7:-/sbin/nologin}"

    if ! getent group "$group" >/dev/null 2>&1; then
        groupadd -r -g "$gid" "$group" 2>/dev/null || true
    fi

    if ! getent passwd "$user" >/dev/null 2>&1; then
        useradd -r -u "$uid" -g "$group" -c "$gecos" -d "$home" -s "$shell" "$user" 2>/dev/null || true
    fi
}

# systemd users
ensure_user systemd-network 192 systemd-network 192 "systemd Network Management" /run/systemd/netif /usr/sbin/nologin
ensure_user systemd-resolve 193 systemd-resolve 193 "systemd Resolver" /run/systemd/resolve /usr/sbin/nologin
ensure_user systemd-timesync 194 systemd-timesync 194 "systemd Time Synchronization" /run/systemd/timesync /usr/sbin/nologin

# polkit
ensure_user polkitd 998 polkitd 998 "User for polkitd" / /usr/sbin/nologin

# D-Bus / messagebus (Fedora name, Azure Linux may have 'dbus' instead)
ensure_user dbus 81 dbus 81 "System message bus" / /usr/sbin/nologin
ensure_user messagebus 81 messagebus 81 "System message bus" / /usr/sbin/nologin

# Common desktop/GNOME users
ensure_user rtkit 172 rtkit 172 "RealtimeKit" /proc /usr/sbin/nologin
ensure_user geoclue 992 geoclue 992 "Geolocation service" /var/lib/geoclue /usr/sbin/nologin
ensure_user pipewire 996 pipewire 996 "PipeWire System Daemon" /var/run/pipewire /usr/sbin/nologin
ensure_user colord 997 colord 997 "Color management daemon" /var/lib/colord /usr/sbin/nologin
ensure_user flatpak 994 flatpak 994 "Flatpak system helper" / /usr/sbin/nologin
ensure_user gdm 42 gdm 42 "GNOME Display Manager" /var/lib/gdm /sbin/nologin

# Verify
echo "=== Created users ==="
getent passwd | grep -E "systemd-network|systemd-resolve|polkitd|dbus|messagebus|rtkit|geoclue|pipewire|colord|flatpak|gdm" || true