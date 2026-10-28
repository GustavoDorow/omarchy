#!/bin/bash
# The lock test twice with the shell's startup traced on one clock.
cd ~/src/omarchy
cpu=$(grep -m1 "model name" /proc/cpuinfo)
echo "guest ${cpu#*: }"
for i in 1 2; do
  echo "== run $i"
  bash test/shell.d/lock-probe-test.sh 2>&1 | grep -E "^PROBE|lock view is built|answered after" | cut -c1-280
done
