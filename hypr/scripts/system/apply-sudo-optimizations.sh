#!/bin/bash

echo "=== Applying Sudo Optimizations ==="

echo "Setting CPU governor to performance..."
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance > "$cpu" 2>/dev/null
done

echo "Tuning CPU idle states..."
for state in /sys/devices/system/cpu/cpu0/cpuidle/state*/disable; do
    echo 1 > "$state" 2>/dev/null
done

lsblk -o NAME,MOUNTPOINT,FSTYPE | grep -E "nvme|sda"

echo ""
echo "=== To enable SSD optimizations, add these options to /etc/fstab ==="
echo "# For SSD root: add 'noatime,nodiratime,discard=async' to mount options"
echo "# Example line in /etc/fstab:"
echo "# UUID=xxx / ext4 noatime,nodiratime,discard=async 0 1"
echo ""

echo "Current kernel cmdline:"
cat /proc/cmdline

echo ""
echo "=== Recommended kernel params for /etc/default/grub ==="
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"quiet resume=UUID=xxx intel_idle.max_cstate=1 processor.max_cstate=1 i915.enable_guc=2 i915.enable_fbc=1 i915.enable_psr=0\""

echo "Enabling TRIM for SSDs..."
systemctl enable fstrim.timer 2>/dev/null
systemctl start fstrim.timer 2>/dev/null

echo ""
echo "=== Verifying optimizations ==="
echo "CPU Governor:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ""
echo "TRIM timer:"
systemctl status fstrim.timer --no-pager 2>/dev/null | head -3

echo ""
echo "=== Done ==="
