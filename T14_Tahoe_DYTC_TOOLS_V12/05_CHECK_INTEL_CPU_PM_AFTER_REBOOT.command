#!/bin/zsh
set -u
BASE="${0:A:h}"
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="$BASE/Reports/T14_Intel_CPU_PM_V57_$STAMP"
mkdir -p "$OUT"
LOG="$OUT/report.txt"
exec > >(tee -a "$LOG") 2>&1

echo '== T14 Intel CPU PM / CPUFriend V57 check =='
date
echo

echo '== Loaded kexts =='
kmutil showloaded 2>/dev/null | egrep -i 'CPUFriend|Lilu|VirtualSMC|SMCProcessor|X86PlatformPlugin' || true
kextstat 2>/dev/null | egrep -i 'CPUFriend|Lilu|VirtualSMC|SMCProcessor|X86PlatformPlugin' || true

echo

echo '== XCPM sysctl =='
sysctl machdep.xcpm.mode machdep.xcpm.vectors_loaded_count machdep.xcpm.bootpst machdep.xcpm.tuib_enabled 2>/dev/null || true

echo

echo '== Plugin / CPUFriend IORegistry hints =='
ioreg -l -w0 2>/dev/null | egrep -i 'X86PlatformPlugin|CPUFriend|cf-frequency-data|plugin-type' | head -80 || true

echo

echo '== Short powermetrics sample =='
sudo powermetrics --samplers cpu_power,smc,thermal -n 1 -i 1000 2>&1 | egrep -i 'Intel energy model|System Average frequency|CPU LIMIT|CPU die temperature|Current pressure|Fan|thermal|performance' || true

echo

echo "DONE"
echo "Report: $LOG"
