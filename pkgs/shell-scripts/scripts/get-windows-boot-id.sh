#!/usr/bin/env bash

# Check if efibootmgr is installed
if ! command -v efibootmgr &> /dev/null
then
    echo "⁉️ Error: 'efibootmgr' could not be found. Please ensure it is installed."
    exit 1
fi

BOOT_ENTRY_LINE=$(efibootmgr -v 2>/dev/null | grep -i "Windows Boot Manager" | head -n 1)

if [ -z "$BOOT_ENTRY_LINE" ]; then
    echo "⁉️ Error: Could not find an EFI boot entry matching 'Windows Boot Manager'."
    exit 1
fi

# The ID is the 4 characters starting at position 5 of the first column (e.g., Boot0001* -> 0001)
WINDOWS_BOOT_ID=$(echo "$BOOT_ENTRY_LINE" | awk '{print substr($1, 5, 4)}')

if [[ "$WINDOWS_BOOT_ID" =~ ^[0-9a-fA-F]{4}$ ]]; then
    echo "$WINDOWS_BOOT_ID"
else
    echo "⁉️ Error: Found an entry but could not extract a valid 4-digit ID."
    echo "Entry line: $BOOT_ENTRY_LINE"
    exit 1
fi
