#!/bin/zsh
set -u
BASE="${0:A:h}"
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$BASE/Reports/T14_Battery_Audio_Status_V58_$STAMP"
mkdir -p "$OUT"
LOG="$OUT/report.txt"
exec > >(tee -a "$LOG") 2>&1

echo '== T14 Battery + Audio status V58 =='
date
echo "Report: $LOG"
echo

echo '== Boot args / macOS =='
sw_vers
nvram boot-args 2>/dev/null || true

echo

echo '== Battery kexts loaded =='
kmutil showloaded 2>/dev/null | egrep -i 'Lilu|VirtualSMC|SMCBattery|ECEnabler|ACPI' || true
kextstat 2>/dev/null | egrep -i 'Lilu|VirtualSMC|SMCBattery|ECEnabler|ACPI' || true

echo

echo '== Battery system profile =='
system_profiler SPPowerDataType 2>/dev/null || true

echo

echo '== pmset battery =='
pmset -g batt 2>/dev/null || true
pmset -g pslog 2>/dev/null | head -25 || true

echo

echo '== IORegistry battery hints =='
ioreg -r -c AppleSmartBattery -l -w0 2>/dev/null || true
ioreg -r -c AppleACPIBatteryManager -l -w0 2>/dev/null || true
ioreg -l -w0 2>/dev/null | egrep -i 'SMCBattery|ECEnabler|BAT0|AppleSmartBattery|BatteryInstalled|DesignCapacity|MaxCapacity|CurrentCapacity|CycleCount|Manufacturer|DeviceName' | head -200 || true

echo

echo '== Audio output and VoodooHDA =='
kmutil showloaded 2>/dev/null | egrep -i 'VoodooHDA|IOAudio|AppleHDA|AppleALC' || true
kextstat 2>/dev/null | egrep -i 'VoodooHDA|IOAudio|AppleHDA|AppleALC' || true
system_profiler SPAudioDataType 2>/dev/null || true

echo

echo '== VoodooHDA installed flags =='
/usr/bin/plutil -p /Library/Extensions/VoodooHDA.kext/Contents/Info.plist 2>/dev/null | /usr/bin/grep -A80 -E 'T14V|MixerValues|NodesToPatch|VoodooHDAEnableVolumeChangeFix|VoodooHDAEnableMuteFix|VoodooHDAEnableHalfVolumeFix|VoodooHDAEnableHalfMicVolumeFix|Boost|LayoutId' || true

echo

echo '== macOS volume settings =='
osascript -e 'get volume settings' 2>/dev/null || true

echo

echo 'DONE'
echo "Report: $LOG"
