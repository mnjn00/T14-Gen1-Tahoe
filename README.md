# Lenovo ThinkPad T14 Gen 1 Intel - macOS Tahoe OpenCore EFI
OpenCore EFI and helper scripts for a Lenovo ThinkPad T14 Gen 1 Intel running macOS Tahoe.

> [!IMPORTANT]
> This repository contains a **sanitized** OpenCore configuration. You must generate and insert your own SMBIOS values before booting.

## Target hardware

| Part | Value |
| --- | --- |
| Model | Lenovo ThinkPad T14 Gen 1 Intel |
| Type | 20S1 class |
| CPU | Intel Core i7-10510U / Comet Lake-U |
| iGPU | Intel UHD Graphics / `8086:9b41` |
| Wi-Fi / BT | Intel AX201 |
| Storage used by maintainer | WD Black SN850 2TB |
| macOS | Tahoe |
| SMBIOS | `MacBookPro16,2` |

## Current status

### Working / reported working

- OpenCore boot and macOS Tahoe install
- Intel UHD graphics acceleration
- Internal display brightness control
- HDMI internal + external dual display
- Wi-Fi and Bluetooth with OpenIntelWireless/OCLP root patch path
- Trackpad, TrackPoint, keyboard, Fn brightness keys
- Battery percentage/basic battery reporting path
- CPU power management with XCPM + CPUFriend data injection
- Fan RPM/control helper path via EC read/write bridge
- Camera / Photo Booth
- Speaker output with VoodooHDA post-install path
- 3.5mm headset microphone
- Universal Clipboard / Handoff-style text and photo transfer
- Wired Sidecar

### Known limits

- Internal digital microphone is not expected to work on this Intel SST/SOF setup.
- AirDrop is not expected to work with Intel AX201/AirportItlwm due to AWDL limitations.
- Wireless Sidecar and Apple Watch Unlock are not expected to be reliable with Intel AX201.
- Wake by keyboard/trackpad was not a target; power-button wake is the accepted path.
- VoodooHDA is installed post-boot into `/Library/Extensions`; it is not an OpenCore EFI kext.

## Before use: generate your own SMBIOS

The committed `EFI/OC/config.plist` has placeholders:

```text
SystemSerialNumber = REPLACE_ME_SERIAL
MLB                = REPLACE_ME_MLB
SystemUUID         = 00000000-0000-0000-0000-000000000000
ROM                = 000000000000
```

Generate your own `MacBookPro16,2` SMBIOS values with GenSMBIOS or another trusted OpenCore workflow, then replace these values before booting.

Do **not** reuse another machine's serial, MLB, UUID, or ROM.

## Repository layout

```text
EFI/                              OpenCore EFI folder, sanitized
T14_Tahoe_DYTC_TOOLS_V12/         Helper scripts and small EC/DYTC tools
VoodooHDA_Tahoe_Guide_V58_*/      Post-install VoodooHDA profile for audio/volume fix
docs/                             Notes and manifests
```

## USB install / test use

Copy `EFI` to the EFI partition of a USB installer, then replace SMBIOS placeholders.

Typical EFI partition layout:

```text
EFI
├── BOOT
└── OC
```

## Install OpenCore to internal EFI without deleting GRUB

If the same disk also has CachyOS/GRUB, do **not** format the EFI partition and do **not** copy over the entire `/EFI` directory.

Use only this idea:

```text
copy this repo's EFI/OC -> internal EFI partition's EFI/OC
preserve existing EFI/GRUB, EFI/cachyos, EFI/BOOT unless you know what you are doing
```

Helper scripts are included:

- `T14_Tahoe_DYTC_TOOLS_V12/10_INSTALL_OC_TO_INTERNAL_EFI_FROM_MACOS.command`
- `T14_Tahoe_DYTC_TOOLS_V12/11_ADD_OPENCORE_BOOT_ENTRY_FROM_CACHYOS.sh`

See `docs/INTERNAL_EFI_INSTALL.md`.

## Post-install helpers

Important scripts:

| Script | Purpose |
| --- | --- |
| `05_CHECK_INTEL_CPU_PM_AFTER_REBOOT.command` | Verify CPUFriend/XCPM state |
| `08_CHECK_BATTERY_AUDIO_STATUS.command` | Gather battery/audio report |
| `09_INSTALL_VOODOOHDA_VOLUME_FIX_V58.command` | Install VoodooHDA external-mic + volume-key fix profile |
| `10_INSTALL_OC_TO_INTERNAL_EFI_FROM_MACOS.command` | Copy OC to internal EFI while preserving GRUB |
| `11_ADD_OPENCORE_BOOT_ENTRY_FROM_CACHYOS.sh` | Add OpenCore UEFI entry from CachyOS |

## Credits

This EFI uses work from the OpenCore and Hackintosh community, including Acidanthera projects, OpenIntelWireless, YogaSMC, VoodooPS2, VoodooHDA, USBToolBox, and related maintainers.

## Disclaimer

This repository is provided for educational/repair/reference use. Hackintosh setups are hardware- and firmware-specific; always keep a bootable USB and a backup of your existing EFI.
