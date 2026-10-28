#!/bin/bash
# quattro's lock budget test and the one that waits for the shell to go quiet,
# 6 times each in this VM.
cd ~/src/omarchy
for variant in red green; do
  cp test/lock-$variant.sh test/shell.d/lock-appear-budget-test.sh
  failed=0 firsts=""
  for i in $(seq 1 6); do
    out=$(bash test/shell.d/lock-appear-budget-test.sh 2>&1) || failed=$(( failed + 1 ))
    firsts="$firsts $(grep -oE "first appears within [0-9]+ms \([0-9]+ms\)|first appearances took [0-9]+ms" <<<"$out" | grep -oE "[0-9]+ms\)?$" | tr -d 'ms)')"
  done
  echo "$variant: failed $failed of 6; fastest first appearances (ms):$firsts"
done
