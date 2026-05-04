# Status Notes

## Strongly working areas

- Tahoe boots through OpenCore.
- Graphics acceleration and brightness work.
- HDMI dual display works with the current framebuffer connector mapping.
- Wi-Fi/Bluetooth work through Intel AX201 kext/OCLP path.
- Trackpad, TrackPoint, keyboard and Fn brightness work.
- CPU power management attaches through XCPM/X86PlatformPlugin, with CPUFriend added.
- Fan EC read/write works through the T14 EC bridge and helper tools.

## Deliberate limitations

- Internal microphone is not treated as fixable in this setup.
- AirDrop/wireless Sidecar/Apple Watch Unlock are limited by Intel AX201/AWDL support.
- Sleep wake by keyboard/trackpad is not targeted; power button wake is acceptable.

## Audio note

Speaker/headset audio uses VoodooHDA post-install rather than AppleALC. The V58 VoodooHDA profile is based on the external headset mic working profile plus VoodooHDA volume/mute fixes.
