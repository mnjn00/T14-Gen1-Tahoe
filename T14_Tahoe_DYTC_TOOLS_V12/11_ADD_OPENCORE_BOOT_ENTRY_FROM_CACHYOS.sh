#!/usr/bin/env bash
set -euo pipefail
LOG="$HOME/t14-opencore-bootentry-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

echo '== T14 add OpenCore UEFI boot entry - CachyOS mode =='
date

fail(){ echo "ERROR: $*" >&2; echo "Log: $LOG" >&2; exit 1; }
command -v lsblk >/dev/null || fail 'lsblk missing'
command -v efibootmgr >/dev/null || fail 'efibootmgr missing; install/use CachyOS live with efibootmgr'

echo
lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,MOUNTPOINTS,MODEL,TRAN

# Pick internal NVMe disk, preferably WD SN850 and around 2TB, otherwise first non-removable nvme.
DISK=""
while read -r name tran size model; do
  if [[ "$name" == nvme*n1 ]]; then
    if echo "$model" | grep -qi 'SN850'; then DISK="/dev/$name"; break; fi
    if [[ -z "$DISK" ]]; then DISK="/dev/$name"; fi
  fi
done < <(lsblk -dn -o NAME,TRAN,SIZE,MODEL | sed 's/[[:space:]][[:space:]]*/ /g')
[ -n "$DISK" ] || fail 'No internal NVMe disk found'
echo "Selected disk: $DISK"

ESP=""
while read -r part fstype label partlabel; do
  if [[ "$fstype" == "vfat" ]] && { [[ "$label" == "EFI" ]] || echo "$partlabel" | grep -qi 'EFI'; }; then
    ESP="/dev/$part"; break
  fi
done < <(lsblk -nr -o NAME,FSTYPE,LABEL,PARTLABEL "$DISK")
[ -n "$ESP" ] || fail "No vfat EFI partition found on $DISK"
echo "Selected ESP: $ESP"

MNT="/mnt/t14-internal-efi"
sudo mkdir -p "$MNT"
if ! mountpoint -q "$MNT"; then
  sudo mount "$ESP" "$MNT"
fi
[ -f "$MNT/EFI/OC/OpenCore.efi" ] || fail "OpenCore.efi not found at $MNT/EFI/OC. Run 10_INSTALL_OC_TO_INTERNAL_EFI_FROM_MACOS.command first."

BACKUP="$HOME/t14-internal-efi-before-bootentry-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
sudo rsync -a "$MNT/" "$BACKUP/"
echo "Backup: $BACKUP"

echo 'Existing boot entries:'
sudo efibootmgr -v || true

if sudo efibootmgr -v | grep -q '\\EFI\\OC\\OpenCore.efi'; then
  echo 'OpenCore boot entry already exists; not adding duplicate.'
else
  PARTNUM="${ESP##*p}"
  if [[ "$PARTNUM" == "$ESP" ]]; then PARTNUM="${ESP##*[!0-9]}"; fi
  sudo efibootmgr -c -d "$DISK" -p "$PARTNUM" -L 'OpenCore' -l '\EFI\OC\OpenCore.efi'
fi

echo 'Boot entries after:'
sudo efibootmgr -v

echo
cat <<TXT
완료. 이제 BIOS/F12 또는 efibootmgr -o 로 OpenCore를 1순위로 두면 USB 없이 macOS 부팅 가능.
GRUB/CachyOS는 지우지 않았음.
Log: $LOG
TXT
