#!/bin/bash
# lock-appear-budget 8 times each: as it runs; with the Mesa shader cache kept
# outside the scratch home and warmed first; and with Qt's QML disk cache kept
# outside it too.
cd ~/src/omarchy
grep -m2 -h -iE "llvmpipe|Using device|renderer" "$XDG_RUNTIME_DIR"/hypr/*/hyprland.log
run() {
  echo "== $1"
  for i in $(seq 1 8); do
    bash test/shell.d/lock-appear-budget-test.sh 2>&1 | grep -E "first appear|reappear|view is built|skip" | tr '\n' ' '
    echo
  done
}
run cold
export MESA_SHADER_CACHE_DIR=$HOME/warm/mesa
bash test/shell.d/lock-appear-budget-test.sh >/dev/null 2>&1
echo "mesa cache: $(du -sh $MESA_SHADER_CACHE_DIR 2>/dev/null | cut -f1)"
run "warm Mesa cache"
export QML_DISK_CACHE_PATH=$HOME/warm/qml
bash test/shell.d/lock-appear-budget-test.sh >/dev/null 2>&1
echo "qml cache: $(du -sh $QML_DISK_CACHE_PATH 2>/dev/null | cut -f1)"
run "warm Mesa and QML caches"
