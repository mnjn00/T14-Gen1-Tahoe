# Installing OpenCore to Internal EFI while Preserving CachyOS/GRUB

Do not format the EFI partition. Do not delete the whole `EFI` directory.

## macOS path

From the USB-booted macOS system, run:

```text
T14_Tahoe_DYTC_TOOLS_V12/10_INSTALL_OC_TO_INTERNAL_EFI_FROM_MACOS.command
```

The script backs up the internal EFI and copies only `EFI/OC`.

## CachyOS path

If the OpenCore UEFI entry is missing, boot CachyOS and run:

```bash
bash /path/to/USB/T14_Tahoe_DYTC_TOOLS_V12/11_ADD_OPENCORE_BOOT_ENTRY_FROM_CACHYOS.sh
```

Manual equivalent, after identifying the internal ESP:

```bash
sudo mkdir -p /mnt/internal-efi /mnt/usb-efi
sudo mount /dev/nvme0n1p1 /mnt/internal-efi
sudo mount /dev/sdX1 /mnt/usb-efi
sudo rsync -a --delete /mnt/usb-efi/EFI/OC/ /mnt/internal-efi/EFI/OC/
sudo efibootmgr -c -d /dev/nvme0n1 -p 1 -L "OpenCore" -l '\EFI\OC\OpenCore.efi'
```

Adjust device names to match `lsblk`.
