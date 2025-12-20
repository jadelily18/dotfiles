#!/usr/bin/env bash
set -euo pipefail

BOOT_ID=$(get-windows-boot-id)

if [ -z "$BOOT_ID" ]; then
    echo "⁉️ Error: Could not determine Windows Boot ID."
    exit 1
fi

echo "🔄 Setting next boot to Windows (Boot ID: $BOOT_ID)"
sudo efibootmgr -n "$BOOT_ID"

echo "🔁 Rebooting now..."
reboot