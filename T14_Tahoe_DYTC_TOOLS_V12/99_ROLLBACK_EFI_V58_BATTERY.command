#!/bin/zsh
set -euo pipefail
EFI='/Volumes/EFI/EFI/OC'
BACKUP='/Volumes/Install macOS Tahoe/T14_Tahoe_DYTC_TOOLS_V12/Backups/EFI_BEFORE_V58_BATTERY_ECEBETA_20260502_071328/OC'
if [ ! -d "$EFI" ]; then echo 'EFI not mounted at /Volumes/EFI/EFI/OC' >&2; exit 2; fi
if [ ! -d "$BACKUP" ]; then echo 'Backup missing: '$BACKUP >&2; exit 3; fi
rsync -a --delete "$BACKUP/" "$EFI/"
sync
echo 'Rolled back EFI V58 battery patch to:'
echo '/Volumes/Install macOS Tahoe/T14_Tahoe_DYTC_TOOLS_V12/Backups/EFI_BEFORE_V58_BATTERY_ECEBETA_20260502_071328'
