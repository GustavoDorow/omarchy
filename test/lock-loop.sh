#!/bin/bash
# The lock budget test 6 times with every first appearance's frames logged.
cd ~/src/omarchy
for i in $(seq 1 6); do
  echo "== run $i"
  bash test/shell.d/lock-probe-test.sh 2>&1 | grep -E "^PROBE|first appear" | cut -c1-260
done
