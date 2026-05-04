#!/bin/zsh
set -u
setopt NULL_GLOB
BASE="${0:A:h}"
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$BASE/Reports/T14_DYTC_Profile_Sweep_V56_$STAMP"
mkdir -p "$OUT"
REPORT="$OUT/report.txt"
PIDS_FILE="/tmp/t14-v56-sweep-pids.$$"
cleanup_load(){
  if [ -f "$PIDS_FILE" ]; then xargs kill < "$PIDS_FILE" 2>/dev/null || true; rm -f "$PIDS_FILE"; fi
  command rm -f /tmp/t14-v56-sweep-*.tmp(N) 2>/dev/null || true
}
trap cleanup_load EXIT INT TERM
section(){ print "\n== $* =="; }
log_status(){
  if [ -x "$BASE/bin/dytcctl" ]; then "$BASE/bin/dytcctl" || true; fi
  if [ -x "$BASE/bin/ecctl" ]; then "$BASE/bin/ecctl" read 0xc4 1 || true; fi
  if [ -x "$BASE/bin/thinkfanctl" ]; then "$BASE/bin/thinkfanctl" status || true; fi
}
set_fanmax(){ if [ -x "$BASE/bin/thinkfanctl" ]; then sudo "$BASE/bin/thinkfanctl" max >/dev/null 2>&1 || true; fi }
set_fanauto(){ if [ -x "$BASE/bin/thinkfanctl" ]; then sudo "$BASE/bin/thinkfanctl" auto >/dev/null 2>&1 || true; fi }
set_mode(){
  local mode="$1"
  case "$mode" in
    balance)
      "$BASE/bin/dytcctl" balance >/dev/null 2>&1 || "$BASE/bin/dytcctl" balanced >/dev/null 2>&1 || true ;;
    perf)
      "$BASE/bin/dytcctl" performance >/dev/null 2>&1 || true ;;
    nolap_perf)
      "$BASE/bin/dytcctl" raw 0x000F1001 >/dev/null 2>&1 || true
      "$BASE/bin/dytcctl" raw 0x0012B001 >/dev/null 2>&1 || true
      "$BASE/bin/dytcctl" raw 0x000F1001 >/dev/null 2>&1 || true ;;
    cql_perf)
      "$BASE/bin/dytcctl" raw 0x001F1001 >/dev/null 2>&1 || true
      "$BASE/bin/dytcctl" raw 0x0012B001 >/dev/null 2>&1 || true ;;
    psc0) "$BASE/bin/dytcctl" psc 0 >/dev/null 2>&1 || true ;;
    psc1) "$BASE/bin/dytcctl" psc 1 >/dev/null 2>&1 || true ;;
    psc2) "$BASE/bin/dytcctl" psc 2 >/dev/null 2>&1 || true ;;
    psc3) "$BASE/bin/dytcctl" psc 3 >/dev/null 2>&1 || true ;;
    psc4) "$BASE/bin/dytcctl" psc 4 >/dev/null 2>&1 || true ;;
    psc5) "$BASE/bin/dytcctl" psc 5 >/dev/null 2>&1 || true ;;
  esac
}
run_load(){
  cleanup_load
  local workers=6
  for i in $(seq 1 "$workers"); do yes > "/tmp/t14-v56-sweep-$i.tmp" & echo $! >> "$PIDS_FILE"; done
}

exec > >(tee "$REPORT") 2>&1
print "== T14 DYTC Profile Sweep V56 =="
date
print "Report folder: $OUT"
print "Goal: find a middle point between V54 cooler/PL1-limited and V55 no-lap hot/thermal-limited."
print "Each mode gets a short 6-worker load sample with fan max. EFI/NVRAM not changed."
section "Apply baseline pmset"
sudo pmset -a lowpowermode 0 powernap 0 tcpkeepalive 0 proximitywake 0 standby 0 autopoweroff 0 hibernatemode 0 || true
sudo pmset -c sleep 0 disksleep 0 displaysleep 20 lowpowermode 0 || true

modes=(balance perf cql_perf nolap_perf psc0 psc1 psc2 psc3 psc4 psc5)
print "\nSUMMARY_TSV mode\tstatus\tpkgW\tfreqMHz\tlimit\ttempC\tfanRPM\tlapCQL"
for mode in $modes; do
  section "Mode $mode"
  cleanup_load
  set_mode "$mode"
  set_fanmax
  sleep 6
  print -- "-- before load status --"
  log_status
  run_load
  sleep 8
  print -- "-- load status --"
  log_status
  PM=$(sudo powermetrics --samplers cpu_power,smc,thermal -n 1 -i 1000 2>&1 || true)
  print "$PM" | egrep -i 'Intel energy model|System Average frequency|CPU LIMIT|CPU die temperature|Current pressure|Fan|thermal|performance' || true
  cleanup_load
  sleep 5
  # Extract rough metrics for summary.
  pkg=$(print "$PM" | awk -F': ' '/Intel energy model/{gsub("W", "", $2); print $2; exit}')
  freq=$(print "$PM" | sed -nE 's/.*\(([0-9.]+) Mhz\).*/\1/p' | head -1)
  limit=$(print "$PM" | awk '/CPU LIMIT/{print $0; exit}')
  temp=$(print "$PM" | sed -nE 's/.*CPU die temperature: ([0-9.]+).*/\1/p' | head -1)
  fan=$("$BASE/bin/thinkfanctl" status 2>/dev/null | sed -nE 's/.*=> ([0-9]+) rpm.*/\1/p' | tail -1)
  cql=$("$BASE/bin/ecctl" read 0xc4 1 2>/dev/null | sed -nE 's/.*CQLS bits.*= ([0-9]+).*/\1/p' | head -1)
  [ -z "${limit:-}" ] && limit="none"
  print "SUMMARY_TSV $mode\tok\t${pkg:-?}\t${freq:-?}\t${limit}\t${temp:-?}\t${fan:-?}\t${cql:-?}"
  sleep 3
done

section "Restore normal auto"
cleanup_load
if [ -x "$BASE/bin/dytcctl" ]; then "$BASE/bin/dytcctl" balance >/dev/null 2>&1 || "$BASE/bin/dytcctl" balanced >/dev/null 2>&1 || true; fi
set_fanauto
sleep 3
log_status
print "\nDONE"
print "Report: $REPORT"
open "$OUT" 2>/dev/null || true
