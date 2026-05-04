#!/bin/zsh
set -u
BASE="${0:A:h}"
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$BASE/Reports/T14_Continuity_BestEffort_$STAMP"
mkdir -p "$OUT"
LOG="$OUT/report.txt"
exec > >(tee -a "$LOG") 2>&1

echo '== T14 Handoff / Universal Clipboard best-effort enable =='
date
echo "Report: $LOG"
echo

echo 'Enabling useractivityd Handoff advertising/receiving for current user...'
defaults -currentHost write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool true
defaults -currentHost write com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool true
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

echo

echo 'Restarting continuity-related user daemons...'
killall useractivityd 2>/dev/null || true
killall sharingd 2>/dev/null || true
killall Finder 2>/dev/null || true
sleep 3

echo

echo 'Current Handoff defaults:'
defaults -currentHost read com.apple.coreservices.useractivityd 2>/dev/null || true

echo

echo 'AWDL check:'
ifconfig awdl0 2>&1 || true

echo

echo 'NOTE:'
echo '- 이 스크립트는 Handoff/Universal Clipboard 쪽 사용자 설정을 켜는 best-effort임.'
echo '- Intel AX201 + AirportItlwm은 AWDL/Continuity 구현 한계가 있어서 AirDrop/Apple Watch Unlock/Continuity Camera까지 보장 못 함.'
echo '- 06 리포트에서 AWDL이 없거나 Intel 드라이버로만 잡히면, 풀 연속성은 Broadcom/Apple 네이티브 무선 하드웨어가 필요함.'

echo

echo 'DONE'
echo "Report: $LOG"
