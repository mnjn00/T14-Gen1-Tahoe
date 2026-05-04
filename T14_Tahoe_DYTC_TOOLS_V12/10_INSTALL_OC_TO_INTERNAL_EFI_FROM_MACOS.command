#!/bin/zsh
set -euo pipefail
BASE="${0:A:h}"
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$BASE/Reports/T14_Internal_OC_Install_$STAMP"
mkdir -p "$OUT"
LOG="$OUT/install.log"
exec > >(tee -a "$LOG") 2>&1

section(){ print "\n== $* =="; }
fail(){ echo "ERROR: $*" >&2; echo "Report: $LOG" >&2; exit 1; }

section 'T14 install OpenCore to internal EFI - macOS mode'
date
sw_vers || true

SRC_OC='/Volumes/EFI/EFI/OC'
[ -f "$SRC_OC/OpenCore.efi" ] || fail "USB OpenCore not mounted at $SRC_OC"
SRC_DEV=$(diskutil info /Volumes/EFI 2>/dev/null | awk -F: '/Device Identifier/{gsub(/^[ \t]+/,"",$2); print $2; exit}')
SRC_WHOLE=$(diskutil info /Volumes/EFI 2>/dev/null | awk -F: '/Part of Whole/{gsub(/^[ \t]+/,"",$2); print $2; exit}')
echo "USB EFI source: /Volumes/EFI ($SRC_DEV on $SRC_WHOLE)"

section 'Disk overview'
diskutil list

section 'Find protected internal T14 disk candidate'
# Guard: do not touch the current Mac internal Apple-only disk. Candidate must be internal, >= 900GB,
# have an EFI partition, and have at least one APFS plus one Linux-ish partition for CachyOS.
CANDIDATES=()
for d in $(diskutil list | awk '/^\/dev\/disk[0-9]+ \(internal, physical\)/{gsub("/dev/", "", $1); print $1}'); do
  info=$(diskutil info "$d" 2>/dev/null || true)
  size_bytes=$(echo "$info" | awk -F'[()]' '/Disk Size/{print $2; exit}' | awk '{print $1}')
  [ -n "$size_bytes" ] || size_bytes=0
  list=$(diskutil list "$d" 2>/dev/null || true)
  echo "-- $d size=$size_bytes --"
  echo "$list"
  if [ "$size_bytes" -ge 900000000000 ] && echo "$list" | grep -qi 'EFI' && echo "$list" | grep -qi 'APFS' && echo "$list" | grep -Eqi 'Linux|Microsoft Basic|Windows_NTFS|Basic Data|Cachy|ext4|btrfs'; then
    CANDIDATES+=("$d")
  fi
done

if [ ${#CANDIDATES[@]} -ne 1 ]; then
  echo "Candidates found: ${CANDIDATES[*]:-none}"
  fail "내장 T14 디스크 후보가 정확히 1개가 아님. 안전상 중단. T14 macOS에서 실행 중인지 확인." 
fi
DISK="${CANDIDATES[1]}"
echo "Selected internal disk: $DISK"

EFI_PART=$(diskutil list "$DISK" | awk '/EFI/{print $NF; exit}')
[ -n "$EFI_PART" ] || fail "No EFI partition found on $DISK"
[ "$EFI_PART" != "$SRC_DEV" ] || fail "Internal EFI candidate equals USB source; refusing"
echo "Internal EFI partition: $EFI_PART"

section 'Mount internal EFI'
MOUNTPOINT=$(diskutil info "$EFI_PART" 2>/dev/null | awk -F: '/Mount Point/{gsub(/^[ \t]+/,"",$2); print $2; exit}')
if [ -z "$MOUNTPOINT" ] || [ "$MOUNTPOINT" = "Not mounted" ]; then
  diskutil mount "$EFI_PART"
  sleep 1
  MOUNTPOINT=$(diskutil info "$EFI_PART" 2>/dev/null | awk -F: '/Mount Point/{gsub(/^[ \t]+/,"",$2); print $2; exit}')
fi
[ -d "$MOUNTPOINT" ] || fail "Could not mount internal EFI partition $EFI_PART"
echo "Internal EFI mounted at: $MOUNTPOINT"

section 'Backup internal EFI before changes'
BACKUP="$BASE/Backups/Internal_EFI_BEFORE_OC_${STAMP}_${EFI_PART}"
mkdir -p "$BACKUP"
rsync -a "$MOUNTPOINT/" "$BACKUP/"
echo "Backup: $BACKUP"

section 'Preserve GRUB/CachyOS and copy only EFI/OC'
mkdir -p "$MOUNTPOINT/EFI"
if [ -d "$MOUNTPOINT/EFI/OC" ]; then
  rsync -a "$MOUNTPOINT/EFI/OC/" "$BACKUP/EFI_OC_before/" || true
fi
rsync -a --delete "$SRC_OC/" "$MOUNTPOINT/EFI/OC/"

section 'Verify internal EFI contents'
[ -f "$MOUNTPOINT/EFI/OC/OpenCore.efi" ] || fail "OpenCore.efi missing after copy"
[ -f "$MOUNTPOINT/EFI/OC/config.plist" ] || fail "config.plist missing after copy"
find "$MOUNTPOINT/EFI" -maxdepth 2 -mindepth 1 -print | sort

section 'Next boot entry step'
cat <<TXT
복사는 완료됨. GRUB/CachyOS 폴더는 삭제하지 않았고 EFI/OC만 복사했음.

이제 ThinkPad BIOS/F12에서 OpenCore 항목이 보이면 그걸 1순위로 올려.
만약 OpenCore 항목이 안 보이면 CachyOS로 부팅해서 USB의 아래 스크립트를 실행:
  11_ADD_OPENCORE_BOOT_ENTRY_FROM_CACHYOS.sh

또는 CachyOS에서 수동으로:
  sudo efibootmgr -c -d /dev/nvme0n1 -p 1 -L "OpenCore" -l '\EFI\OC\OpenCore.efi'
TXT

sync
echo "DONE"
echo "Report: $LOG"
