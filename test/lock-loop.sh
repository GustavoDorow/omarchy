#!/bin/bash
# The lock budget test 6 times as it runs and 6 times with 3 s between the
# lock service answering and the first appearance.
cd ~/src/omarchy
for settle in "" 3; do
  echo "#### settle=${settle:-none}"
  for i in $(seq 1 6); do
    PROBE_SETTLE=$settle bash test/shell.d/lock-probe-test.sh 2>&1 | grep -E "^PROBE round [0-9] (first|layers)|first appear" | cut -c1-400
  done
done
