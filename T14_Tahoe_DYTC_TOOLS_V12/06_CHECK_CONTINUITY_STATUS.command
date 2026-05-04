#!/bin/zsh
set -u
BASE="${0:A:h}"
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$BASE/Reports/T14_Continuity_Status_$STAMP"
mkdir -p "$OUT"
LOG="$OUT/report.txt"
exec > >(tee -a "$LOG") 2>&1

echo '== T14 Continuity / Handoff / AirDrop status =='
date
echo "Report: $LOG"
echo

echo '== Loaded Wi-Fi / Bluetooth kexts =='
kmutil showloaded 2>/dev/null | egrep -i 'AirportItlwm|itlwm|IO80211|IOSkywalk|IntelBluetooth|IntelBTPatcher|BlueToolFixup|Brcm|FeatureUnlock' || true
kextstat 2>/dev/null | egrep -i 'AirportItlwm|itlwm|IO80211|IOSkywalk|IntelBluetooth|IntelBTPatcher|BlueToolFixup|Brcm|FeatureUnlock' || true

echo

echo '== Network hardware ports =='
networksetup -listallhardwareports 2>/dev/null || true

echo

echo '== Wi-Fi interfaces and AWDL =='
ifconfig 2>/dev/null | egrep '^[a-z0-9]+:|status:|ether |awdl|llw' || true
echo
ifconfig awdl0 2>&1 || true
echo
ifconfig llw0 2>&1 || true

echo

echo '== Wi-Fi system profile summary =='
system_profiler SPAirPortDataType 2>/dev/null | egrep -i 'Software Versions|CoreWLAN|IO80211|Interfaces|en[0-9]|Card Type|Firmware|Locale|Country|Current Network|PHY Mode|Security|AirDrop|Auto Unlock|Handoff|Supported' || true

echo

echo '== Bluetooth system profile summary =='
system_profiler SPBluetoothDataType 2>/dev/null | egrep -i 'Bluetooth|Address|State|Chipset|Firmware|Transport|Handoff|Instant Hot|Discoverable|Connectable|Supported|Vendor|Product' || true

echo

echo '== Handoff user defaults =='
defaults -currentHost read com.apple.coreservices.useractivityd 2>/dev/null || true

echo

echo '== sharingd / bluetooth recent log hints =='
log show --last 10m --style compact --predicate 'process == "sharingd" OR process == "bluetoothd" OR process == "useractivityd"' 2>/dev/null | egrep -i 'handoff|continuity|clipboard|airdrop|awdl|bluetooth|error|fail|denied' | tail -120 || true

echo

echo '== Verdict hints =='
if ifconfig awdl0 >/dev/null 2>&1; then
  echo 'AWDL_INTERFACE=present'
else
  echo 'AWDL_INTERFACE=missing_or_unavailable'
fi
if kmutil showloaded 2>/dev/null | grep -qi 'AirportItlwm'; then
  echo 'WIFI_DRIVER=AirportItlwm_Intel'
else
  echo 'WIFI_DRIVER=unknown_or_not_loaded'
fi
if kmutil showloaded 2>/dev/null | grep -qi 'IntelBluetoothFirmware'; then
  echo 'BT_DRIVER=IntelBluetoothFirmware'
else
  echo 'BT_DRIVER=unknown_or_not_loaded'
fi

echo

echo 'DONE'
echo "Report: $LOG"
