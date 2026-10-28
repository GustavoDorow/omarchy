#!/bin/bash
# The lock test's view build and first appearance with llvmpipe's default
# threads, one thread, and two, three times each on this runner.
cd ~/src/omarchy
cpu=$(grep -m1 "model name" /proc/cpuinfo)
echo "guest ${cpu#*: }"
for threads in default 1 2; do
  for i in 1 2 3; do
    if [[ $threads == "default" ]]; then
      out=$(bash test/shell.d/lock-probe-test.sh 2>&1 || true)
    else
      out=$(LP_NUM_THREADS=$threads bash test/shell.d/lock-probe-test.sh 2>&1 || true)
    fi
    speed=$(grep -oE "speed_percent=[0-9]+" <<<"$out" | head -1)
    ready=$(grep -oE "ready_ms=[0-9]+" <<<"$out" | cut -d= -f2 | sort -n | head -1)
    echo "THREADS=$threads run=$i $speed ready_best=$ready | $(grep -oE "(ok|not ok) - lock (view|screen)[^(]*(\([0-9]+ms\))?" <<<"$out" | tr '\n' ';')"
  done
done
