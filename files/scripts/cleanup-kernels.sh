#!/bin/bash
set -euo pipefail

echo "=== Kernels before cleanup ==="
ls -la /lib/modules/
rpm -qa | grep ^kernel | sort

# Keep only the latest Fedora kernel (7.0.12)
# Remove Azure kernel and old FC43 kernel
echo "Removing old kernels..."

# Remove Azure Linux kernel
rpm -e --nodeps kernel-6.18.31-1.5.azl4 || true
rpm -e --nodeps kernel-core-6.18.31-1.5.azl4 || true
rpm -e --nodeps kernel-modules-6.18.31-1.5.azl4 || true
rpm -e --nodeps kernel-modules-core-6.18.31-1.5.azl4 || true

# Remove old FC43 6.17.1 kernel
rpm -e --nodeps kernel-6.17.1-300.fc43 || true
rpm -e --nodeps kernel-core-6.17.1-300.fc43 || true
rpm -e --nodeps kernel-modules-6.17.1-300.fc43 || true
rpm -e --nodeps kernel-modules-core-6.17.1-300.fc43 || true

echo "=== Kernels after cleanup ==="
ls -la /lib/modules/
rpm -qa | grep ^kernel | sort
