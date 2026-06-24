


```bash
cat ~/.config/N4P1x/.current-theme

ls ~/.config/N4P1x/*/
```


```bash
bash -x ~/.config/N4P1x/hooks/01-gtk.sh
```


```bash
~/.config/hypr/scripts/theme/sync-all

~/.config/hypr/scripts/theme/verify
```



```bash
cat ~/.config/gtk-3.0/settings.ini

nwg-look -s <theme>

~/.config/N4P1x/N4P1x switch <current-theme>
```


```bash
cat ~/.config/qt5ct/qt5ct.conf
cat ~/.config/qt6ct/qt6ct.conf

```


```bash
touch ~/.config/alacritty/alacritty.toml

killall -SIGUSR1 kitty

killall -SIGUSR2 ghostty
```


```bash
cat ~/.config/waybar/style.css

pkill waybar && uwsm-app -- waybar &
```


```bash
ls -la ~/.config/rofi/config.rasi
cat ~/.config/rofi/config.rasi | head

pkill rofi
```


```bash
cat ~/.config/mako/colors

pkill mako && uwsm-app -- mako &
```


```bash
ls -la ~/.config/swaync/matugen/
cat ~/.config/swaync/matugen/colors.css

pkill swaync && uwsm-app -- swaync &
```


```bash
cat ~/.config/hypr/theme/colors.conf

hyprctl reload
```


```bash
ls ~/.mozilla/firefox/*/chrome/

cp ~/.config/N4P1x/<theme>/.config/gtk-3.0/colors.css \
   ~/.mozilla/firefox/*/chrome/colors.css

```


```bash
cat ~/.config/Code/User/settings.json | grep workbench

code --disable-gpu
```



```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```


```bash
free -h

sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```


```bash
glxinfo | grep "OpenGL renderer"

env = GBM_BACKEND,intel
env = LIBVA_DRIVER_NAME,iHD
```


```bash
hyprctl keyword general "vsync=true"

```



```bash
waybar 2>&1

cat ~/.config/waybar/config.json
```


```bash
hyprctl bindings

hyprctl reload
```


```bash
systemctl --user status theme-daemon

systemctl --user restart theme-daemon
```


```bash
~/.config/hypr/scripts/theme/verify

~/.config/hypr/scripts/system/monitor

ps aux | grep -E "waybar|mako|swaync"

journalctl -xe
```


```bash
N4P1x switch espresso

~/.config/hypr/scripts/theme/sync-all

hyprctl reload
```
