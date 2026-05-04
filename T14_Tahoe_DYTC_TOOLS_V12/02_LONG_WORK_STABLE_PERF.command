#!/bin/zsh
set -u
setopt NULL_GLOB
BASE="${0:A:h}"
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$BASE/Reports/T14_Set_Cool_Sustained_FanMax_V56_$STAMP"
mkdir -p "$OUT"
REPORT="$OUT/report.txt"
exec > >(tee "$REPORT") 2>&1
section(){ print "\n== $* =="; }
print "== T14 Cool Sustained FanMax V56 =="
date
print "Report folder: $OUT"
print "Runtime profile: avoid V55 thermal-limit by using DYTC balance + fan max. No EFI/NVRAM changes."
section "Apply pmset"
sudo pmset -a lowpowermode 0 powernap 0 tcpkeepalive 0 proximitywake 0 standby 0 autopoweroff 0 hibernatemode 0 || true
sudo pmset -c sleep 0 disksleep 0 displaysleep 20 lowpowermode 0 || true
section "DYTC balance + fan max"
if [ -x "$BASE/bin/dytcctl" ]; then "$BASE/bin/dytcctl" balance || "$BASE/bin/dytcctl" balanced || true; sleep 1; "$BASE/bin/dytcctl" || true; fi
if [ -x "$BASE/bin/thinkfanctl" ]; then sudo "$BASE/bin/thinkfanctl" max || true; sleep 8; "$BASE/bin/thinkfanctl" status || true; fi
if [ -x "$BASE/bin/ecctl" ]; then "$BASE/bin/ecctl" read 0xc4 1 || true; fi
section "pmset/thermal"
pmset -g therm 2>/dev/null || true
print "\nDONE"
print "Report: $REPORT"
open "$OUT" 2>/dev/null || true
