

- Arch Linux (or derivative)
- Hyprland (Wayland compositor)
- System: Intel i5-6300U, HD Graphics 520, 8GB RAM, 120GB SSD (optimized for this, scales to other hardware)



```bash
sudo pacman -S hyprland waybar wofi mako swaynotificationcenter \
    alacritty kitty ghostty btop cava starship \
    nwg-look qt5ct qt6ct \
    rofi-lpass \
    brightnessctl volumectl playerctl \
    jq dbus

sudo pacman -S gpick flameshot loupe

sudo pacman -S ttf-jetbrains-mono ttf-fira-code ttf-nerd-fonts-symbols
```


```bash
mkdir -p ~/.config/hypr/scripts/{theme,system}
mkdir -p ~/.config/N4P1x
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
mkdir -p ~/.config/waybar ~/.config/rofi ~/.config/mako
mkdir -p ~/.config/alacritty ~/.config/kitty ~/.config/ghostty
mkdir -p ~/.config/btop/themes ~/.config/cava
```


```bash
```


```
~/.config/
├── hypr/
│   ├── hyprland.conf     # Main config
│   ├── bindings.conf    # Keybindings
│   ├── autostart.conf  # Startup apps
│   ├── animations.conf # No animations (performance)
│   ├── theme/colors.conf  # Theme colors
│   ├── scripts/
│   │   ├── theme/
│   │   │   ├── sync-all       # Full theme sync
│   │   │   ├── verify        # Theme verification
│   │   │   └── auto-switch   # Time-based switching
│   │   └── system/
│   │       ├── apply-optimizations  # Run on login
│   │       ├── hardware-optimize  # CPU/GPU/RAM
│   │       └── monitor          # Dashboard
│   └── docs/
│       ├── N4P1X.md
│       ├── PERFORMANCE.md
│       └── TROUBLESHOOTING.md
│
├── N4P1x/
│   ├── N4P1x           # Theme CLI
│   ├── hooks/             # Theme hooks
│   │   ├── 01-gtk.sh    # Main hook
│   │   ├── 00-*.sh      # Terminals
│   │   └── 40-*.sh     # Apps
│   ├── themes/           # Themes (symlink)
│   └── base-gtk3.css    # Base styles
│
├── gtk-3.0/
│   ├── gtk.css          # Generated
│   └── settings.ini    # Theme name
├── gtk-4.0/
│   ├── gtk.css         # Generated
│   └── settings.ini   # Theme name
├── qt5ct/qt5ct.conf  # Qt5 theme
├── qt6ct/qt6ct.conf  # Qt6 theme
├── waybar/
│   ├── config.json     # Bar config
│   └── style.css    # Generated
├── rofi/
│   ├── config.rasi  # Generated
│   └── themes/      # Rofi themes
├── mako/
│   └── config       # Mako config
└── swaync/
    └── config.json  # SwayNC config
```



```bash
N4P1x switch <theme>

N4P1x list

~/.config/hypr/scripts/theme/verify

~/.config/hypr/scripts/theme/sync-all

~/.config/hypr/scripts/theme/auto-switch
```


```bash
~/.config/hypr/scripts/system/apply-optimizations

~/.config/hypr/scripts/system/hardware-optimize

~/.config/hypr/scripts/system/monitor
```


| Key | Action |
|-----|-------|
| Super+Enter | Terminal |
| Super+Q | Close window |
| Super+F | Fullscreen |
| Super+Space | App launcher |
| Super+1-9 | Workspace |
| Super+Shift+[1-9] | Move to workspace |
| Super+Mouse | Resize/drag |
| Super+Ctrl+T | Switch theme |
| Super+Ctrl+L | Next theme |
| Super+Ctrl+V | Verify theme |
| Super+Shift+A | Toggle animations |


**espresso** - Dark coffee theme with warm browns

Files included per theme:
- GTK3/GTK4 colors
- Waybar colors
- Hyprland borders
- Rofi config
- Mako colors
- SwayNC colors
- Terminal colors (Alacritty, Kitty, Ghostty)
- Starship prompt
- btop theme
- Cava config
- rmpc theme
- Yazi theme
- VS Code settings
- Firefox colors
- Neovim colors


- Alacritty - GPU-accelerated
- Kitty - GPU-accelerated  
- Ghostty - Native Wayland

- Waybar - Status bar
- Rofi - App launcher
- Wofi - Minimal launcher

- Mako - Wayland notifications
- SwayNC - Notification center

- btop - System monitor
- Cava - Audio visualizer
- brightnessctl - Backlight
- volumectl - Audio

- mpd/rmpc - Music
- Vesktop - Discord replacement
- Spicetify - Spotify


1. Login to Hyprland
2. Run optimizations:
   ```bash
   ~/.config/hypr/scripts/system/apply-optimizations
   ```
3. Set theme:
   ```bash
   N4P1x switch espresso
   ```
4. Verify:
   ```bash
   ~/.config/hypr/scripts/theme/verify
   ```



```bash
systemctl --user enable optimization.service

systemctl --user enable theme-daemon.service
```


Install recommended fonts:
```bash
```


Install GTK themes:
```bash
```


```bash
~/.config/hypr/scripts/theme/sync-all

~/.config/hypr/scripts/theme/verify
```


```bash
tar -czvf config-backup.tar.gz ~/.config/hypr ~/.config/N4P1x ~/.config/gtk-3.0 ~/.config/gtk-4.0

tar -czvf themes-backup.tar.gz ~/.config/N4P1x/*/
```
