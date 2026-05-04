#!/bin/zsh
set -u
setopt NULL_GLOB
BASE="${0:A:h}"
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$BASE/Reports/T14_Set_Normal_Auto_V55_$STAMP"
mkdir -p "$OUT"
REPORT="$OUT/report.txt"
exec > >(tee "$REPORT") 2>&1
section(){ print "\n== $* =="; }
print "== T14 Normal / Auto V55 =="
date
print "Report folder: $OUT"
section "DYTC balance"
if [ -x "$BASE/bin/dytcctl" ]; then "$BASE/bin/dytcctl" balance || "$BASE/bin/dytcctl" balanced || true; sleep 1; "$BASE/bin/dytcctl" || true; fi
section "Fan auto"
if [ -x "$BASE/bin/thinkfanctl" ]; then sudo "$BASE/bin/thinkfanctl" auto || true; sleep 3; "$BASE/bin/thinkfanctl" status || true; fi
section "CQLS observe only"
if [ -x "$BASE/bin/ecctl" ]; then "$BASE/bin/ecctl" read 0xc4 1 || true; fi
print "\nDONE"
print "Report: $REPORT"
open "$OUT" 2>/dev/null || true
