#!/bin/bash
# Candidate calibrations beside the lock test's view build, on this runner.
cd ~/src/omarchy
cpu=$(grep -m1 "model name" /proc/cpuinfo)
echo "guest ${cpu#*: }"

best_ms() {
  local best="" start end ms
  for _ in 1 2 3 4 5; do
    start=$EPOCHREALTIME
    "$@" >/dev/null 2>&1 || true
    end=$EPOCHREALTIME
    ms=$(( (${end/[.,]/} - ${start/[.,]/}) / 1000 ))
    if [[ -z $best ]] || (( ms < best )); then best=$ms; fi
  done
  echo "$best"
}
exec_true() { for _ in {1..100}; do /usr/bin/true; done; }
bash_loop() { local i; for (( i = 0; i < 300000; i++ )); do :; done; }
qs_version() { for _ in {1..10}; do quickshell --version; done; }
minimal=$(mktemp -d)
cat >"$minimal/shell.qml" <<'QML'
import QtQuick
import Quickshell
ShellRoot { Component.onCompleted: Qt.quit() }
QML
qs_minimal() { XDG_RUNTIME_DIR=$(mktemp -d) HOME=$minimal timeout 20 quickshell -p "$minimal/shell.qml" --no-color; }

for i in 1 2 3; do
  c1=$(best_ms exec_true) c2=$(best_ms bash_loop) c3=$(best_ms qs_version) c4=$(best_ms qs_minimal)
  out=$(bash test/shell.d/lock-probe-test.sh 2>&1 || true)
  speed=$(grep -oE "speed_percent=[0-9]+" <<<"$out" | head -1)
  ready=$(grep -oE "ready_ms=[0-9]+" <<<"$out" | cut -d= -f2 | sort -n | head -1)
  verdict=$(grep -oE "(ok|not ok) - lock view is built within [0-9]+ms" <<<"$out")
  echo "CALIB run=$i exec_true=$c1 bash_loop=$c2 qs_version=$c3 qs_minimal=$c4 $speed ready_best=$ready | $verdict"
done
