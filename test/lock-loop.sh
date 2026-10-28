#!/bin/bash
# The view-build check on this runner: #16896's test (red), the one budgeted
# against the shell's own start (green), and green against a lock service
# that takes an extra second to build (regression), three times each.
cd ~/src/omarchy
cpu=$(grep -m1 "model name" /proc/cpuinfo)
echo "guest ${cpu#*: }"
service=shell/plugins/lock/Service.qml
cp "$service" /tmp/Service.qml.orig
for variant in green regression; do
  cp /tmp/Service.qml.orig "$service"
  if [[ $variant == "regression" ]]; then
    sed -i '0,/^  Component.onCompleted: {/s//  Component.onCompleted: {\n    var slowUntil = Date.now() + 1000\n    while (Date.now() < slowUntil) {}/' "$service"
    grep -c "slowUntil" "$service"
    cp test/lock-green.sh test/shell.d/lock-appear-budget-test.sh
  else
    cp test/lock-$variant.sh test/shell.d/lock-appear-budget-test.sh
  fi
  for i in 1 2 3 4; do
    out=$(bash test/shell.d/lock-appear-budget-test.sh 2>&1 || true)
    echo "VARIANT=$variant run=$i | $(grep -oE "(ok|not ok) - lock (view|screen)[^;]*" <<<"$out" | tr '\n' ';' | sed "s/;/,/g" | cut -c1-330) | $(grep -oE "answered after [0-9]+ms[^.]*" <<<"$out" | head -1)"
  done
done
cp /tmp/Service.qml.orig "$service"
