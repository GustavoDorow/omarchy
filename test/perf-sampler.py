# Every 100 ms: CPU time per CPU, disk counters, pressure stall totals.
# Disks: every whole disk and device-mapper device, or the names in
# SAMPLER_DISKS (space-separated, e.g. "nvme1n1 dm-1").
import os, signal, sys, time


def stop(*_):
    raise KeyboardInterrupt


# A background job of a script starts with SIGINT ignored.
signal.signal(signal.SIGINT, stop)
signal.signal(signal.SIGTERM, stop)
out = open(sys.argv[1], "w", buffering=1 << 20)
files = ["/proc/stat", "/proc/diskstats", "/proc/pressure/cpu", "/proc/pressure/io", "/proc/pressure/memory", "/proc/loadavg", "/proc/meminfo", "/proc/vmstat"]
MEM = ("MemFree:", "Cached:", "Dirty:", "Writeback:", "Shmem:", "AnonPages:")
VM = ("pgpgin", "pgpgout", "pgfault", "pgmajfault", "pgscan_kswapd", "pgscan_direct", "pgsteal_kswapd", "nr_dirtied", "nr_written")
DISKS = os.environ.get("SAMPLER_DISKS", "").split()


def wanted(name):
    if DISKS:
        return name in DISKS
    # Partitions are counted in their disk; loop, ram and zram are noise.
    return (os.path.exists(f"/sys/block/{name}") and
            not name.startswith(("loop", "ram", "zram")))


nxt = time.monotonic()
try:
    while True:
        out.write(f"T {time.monotonic():.6f}\n")
        for f in files:
            try:
                for line in open(f):
                    if f == "/proc/stat" and not line.startswith("cpu"):
                        continue
                    if f == "/proc/diskstats" and not wanted(line.split()[2]):
                        continue
                    if f == "/proc/meminfo" and not line.startswith(MEM):
                        continue
                    if f == "/proc/vmstat" and line.split()[0] not in VM:
                        continue
                    out.write(f"{f.rsplit('/', 1)[1] if 'pressure' not in f else 'psi_' + f.rsplit('/', 1)[1]} {line}")
            except OSError:
                pass
        nxt += 0.1
        time.sleep(max(0, nxt - time.monotonic()))
except KeyboardInterrupt:
    pass
out.close()
