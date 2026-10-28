#!/bin/bash
# The slowest files alone on a quiet machine, twice each: wall, user and sys
# seconds, and how many processes the whole machine forked meanwhile.
cd ~/src/omarchy
for name in luks-rekey-journal drive-password agent-usage-partition plymouth-set realtime-repair runtime-smoke channel-sudo-boundary nopasswd-sudo-expiry menu-images agent-account update-stay-awake-security hermes-desktop-install privileged-heredoc; do
  for i in 1 2; do
    forks=$(awk '/^processes/ {print $2}' /proc/stat) faults=$(awk '/^pgfault / {print $2}' /proc/vmstat)
    TIMEFORMAT="%R %U %S"
    t=$( { time bash test/shell.d/$name-test.sh >/dev/null 2>&1; } 2>&1 )
    echo "$name run=$i wall_user_sys=$t forks=$(( $(awk '/^processes/ {print $2}' /proc/stat) - forks )) faults=$(( $(awk '/^pgfault / {print $2}' /proc/vmstat) - faults ))"
  done
done
