#!/bin/zsh
set -u
setopt NULL_GLOB
BASE="${0:A:h}"
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$BASE/Reports/T14_Set_Burst_Performance_FanMax_V56_$STAMP"
mkdir -p "$OUT"
REPORT="$OUT/report.txt"
exec > >(tee "$REPORT") 2>&1
section(){ print "\n== $* =="; }
print "== T14 Burst Performance FanMax V56 =="
date
print "Report folder: $OUT"
print "Runtime profile: max burst performance. V55 showed this can hit 97-98C under sustained 6-thread load, so use for short bursts only."
section "Apply pmset + no-lap performance + fan max"
sudo pmset -a lowpowermode 0 powernap 0 tcpkeepalive 0 proximitywake 0 standby 0 autopoweroff 0 hibernatemode 0 || true
sudo pmset -c sleep 0 disksleep 0 displaysleep 20 lowpowermode 0 || true
if [ -x "$BASE/bin/dytcctl" ]; then
  "$BASE/bin/dytcctl" raw 0x000F1001 || true
  sleep 1
  "$BASE/bin/dytcctl" raw 0x0012B001 || true
  sleep 1
  "$BASE/bin/dytcctl" raw 0x000F1001 || true
  sleep 1
  "$BASE/bin/dytcctl" || true
fi
if [ -x "$BASE/bin/thinkfanctl" ]; then sudo "$BASE/bin/thinkfanctl" max || true; sleep 8; "$BASE/bin/thinkfanctl" status || true; fi
if [ -x "$BASE/bin/ecctl" ]; then "$BASE/bin/ecctl" read 0xc4 1 || true; fi
print "\nDONE"
print "Report: $REPORT"
open "$OUT" 2>/dev/null || true
