#!/bin/zsh
set -euo pipefail
BASE="${0:A:h}"
USB_ROOT="${BASE:h}"
SRC="$USB_ROOT/VoodooHDA_Tahoe_Guide_V58_ExternalMic_VolumeFix"
KEXT="$SRC/VoodooHDA.kext"
PREF="$SRC/VoodooHDA.prefPane"
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$BASE/Reports/T14_VoodooHDA_VolumeFix_V58_$STAMP"
mkdir -p "$OUT"
LOG="$OUT/install.log"
exec > >(tee -a "$LOG") 2>&1

section(){ print "\n== $* =="; }
section 'T14 VoodooHDA V58 external mic + volume key fix'
date
sw_vers || true

section 'Source flags'
[ -d "$KEXT" ] || { echo "ERROR: missing $KEXT"; exit 2; }
/usr/bin/plutil -p "$KEXT/Contents/Info.plist" | /usr/bin/grep -A90 -E 'T14V58|MixerValues|NodesToPatch|VoodooHDAEnableVolumeChangeFix|VoodooHDAEnableMuteFix|VoodooHDAEnableHalfVolumeFix|VoodooHDAEnableHalfMicVolumeFix|Boost|LayoutId' || true

section 'Backup installed VoodooHDA'
if [ -d /Library/Extensions/VoodooHDA.kext ]; then
  sudo rm -rf "$OUT/VoodooHDA.installed.before.kext"
  sudo cp -R /Library/Extensions/VoodooHDA.kext "$OUT/VoodooHDA.installed.before.kext" || true
fi

section 'Install V58 VoodooHDA'
sudo rm -rf /Library/Extensions/VoodooHDA.kext
sudo cp -R "$KEXT" /Library/Extensions/
sudo chown -R root:wheel /Library/Extensions/VoodooHDA.kext
sudo chmod -R 755 /Library/Extensions/VoodooHDA.kext

section 'Install prefPane'
if [ -d "$PREF" ]; then
  mkdir -p "$HOME/Library/PreferencePanes"
  rm -rf "$HOME/Library/PreferencePanes/VoodooHDA.prefPane"
  cp -R "$PREF" "$HOME/Library/PreferencePanes/"
fi

section 'Rebuild kernel collections'
sudo kmutil install --update-all --volume-root / || sudo kextcache -i /

section 'Restart audio'
sudo killall coreaudiod 2>/dev/null || true
sleep 2

section 'Status after install'
kmutil showloaded 2>/dev/null | grep -Ei 'VoodooHDA|IOAudio|AppleALC|AppleHDA|Lilu' || true
system_profiler SPAudioDataType || true
osascript -e 'get volume settings' || true

section 'Done'
echo '재부팅 1회 필요.'
echo '재부팅 후 스피커 출력, 볼륨키 실제 음량 변화, 음소거, 3.5mm 헤드셋 마이크 확인.'
echo "Report: $OUT"
