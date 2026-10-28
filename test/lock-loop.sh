#!/bin/bash
# The proposal's lock test four times on this runner, every failure in full.
cd ~/src/omarchy
cpu=$(grep -m1 "model name" /proc/cpuinfo)
echo "guest ${cpu#*: }"
cp test/lock-green.sh test/shell.d/lock-appear-budget-test.sh
for i in 1 2 3 4; do
  if out=$(bash test/shell.d/lock-appear-budget-test.sh 2>&1); then
    echo "RESULT run=$i pass | $(grep -oE "lock view is built within [0-9]+ms of shell start \([0-9]+ms; the shell answered after [0-9]+ms\)" <<<"$out")"
  else
    echo "RESULT run=$i FAIL | $(grep -E "^not ok" <<<"$out" | tr '\n' ' ')"
    grep -vE "^\s*(DEBUG|INFO)" <<<"$out" | tail -25 | sed 's/^/  /' | cut -c1-240
  fi
done
