

This guide covers all performance optimizations for the Arch Linux Hyprland rice.Optimized for: Intel i5-6300U, HD Graphics 520, 8GB RAM, 120GB SSD


Run all optimizations at once:

```bash
~/.config/hypr/scripts/system/apply-optimizations

sudo ~/.config/hypr/scripts/system/apply-sudo-optimizations.sh
```



```bash
sudo cpupower frequency-set -g performance

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

**Verify:**
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```


```bash
echo 1 | sudo tee /sys/devices/system/cpu/cpu0/cpuidle/state*/disable
```

**In /etc/default/grub:**
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_idle.max_cstate=1 processor.max_cstate=1"
```



**In /etc/default/grub:**
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet i915.enable_guc=2 i915.enable_fbc=1 i915.enable_psr=0"
```


**Create /etc/modprobe.d/i915.conf:**
```bash
options i915 enable_guc=2 enable_fbc=1 enable_psr=0 modeset=1
```


```bash
dmesg | grep i915

glxinfo | grep "OpenGL renderer"
```



```bash
echo 10 | sudo tee /proc/sys/vm/swappiness
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-memory.conf
```


```bash
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```


**Create /etc/sysctl.d/99-memory.conf:**
```bash
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=15
vm.dirty_background_ratio=5
```



**Check current fstab:**
```bash
cat /etc/fstab
```

**Add to mount options:** `noatime,nodiratime,discard=async`

Example:
```
UUID=xxx / ext4 noatime,nodiratime,discard=async 0 1
```


```bash
sudo systemctl enable --now fstrim.timer

systemctl status fstrim.timer
```


```bash
cat /sys/block/sda/queue/scheduler

echo none | sudo tee /sys/block/sda/queue/scheduler
```



**In ~/.config/hypr/animations.conf:**
```hypr
animations {
    enabled = false
    
    bezier = easeOut, 0.25, 0.1, 0.25, 1
    bezier = linear, 0, 0, 1, 1
}

general {
    gaps_in = 5
    gaps_out = 5
    border_size = 1
    "col.active_border" = rgba(ffffffee)
    "col.inactive_border" = rgba(444444aa)
}

decoration {
    shadow = false
    blur {
        enabled = false
    }
    dim_inactive = false
    dim_strength = 0
}
```


**In ~/.config/hypr/envs.conf:**
```hypr
env = GBM_BACKEND,intel
env = LIBVA_DRIVER_NAME,iHD
env = MESA_LOAD_DRIVER,iris
env = XWAYLAND_FORCE_GRAB,0
```



1. Go to `about:config`
2. Set:
   - `widget.backend=wayland`
   - `gfx.webrender.all=true`
   - `layers.acceleration.enabled=true`


```bash
ELECTRON_OZONE_PLATFORM_HINT=wayland
```


**In ~/.config/qt5ct/qt5ct.conf:**
```
[General]
force_raster_widgets=1
```



```bash
sudo sed -i 's/ silent//' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```


```bash
systemctl list-units --type=service --state=running

systemctl disable --now bluetooth
systemctl disable --now cups
```



```bash
~/.config/hypr/scripts/system/monitor
```


```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

free -h

glxinfo | grep "OpenGL renderer"

iotop
```


| Script | Purpose |
|--------|---------|
| `apply-optimizations` | User-level optimizations |
| `hardware-optimize` | CPU/GPU/RAM configs |
| `visual-optimize` | DPI, fonts, compositor |
| `monitor` | Real-time dashboard |
| `center` | Master control |


- [ ] CPU governor set to performance
- [ ] i915 modules configured
- [ ] SSD TRIM enabled
- [ ] Swapiness < 20
- [ ] Animations disabled
- [ ] Shadows disabled
- [ ] Blur disabled
- [ ] Browser GPU acceleration enabled
