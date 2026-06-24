

catbug0x1 is a centralized theme management system for Arch Linux that propagates theme changes instantly across ALL applications in the system. Built for Hyprland/Wayland with support for X11 apps via GTK/Qt.


```bash
catbug0x1 switch <theme-name>

catbug0x1 list

~/.config/hypr/scripts/theme/verify

~/.config/hypr/scripts/theme/sync-all
```


| Theme | Category | Files |
|-------|----------|-------|
| espresso | Dark | 17 configs |
| forest | Dark | 17 configs |
| gruvbox-material | Dark | 17 configs |
| kanagawa | Dark | 17 configs |
| nordic | Dark | 17 configs |
| rose-pine | Dark | 17 configs |
| sakura | Dark | 17 configs |
| tokyo-night | Dark | 17 configs |
| void | Dark | 17 configs |
| zen | Dark | 17 configs |


- **Alacritty** - `~/.config/alacritty/colors.toml`
- **Kitty** - `~/.config/kitty/colors.conf`
- **Ghostty** - `~/.config/ghostty/colors`
- **Tmux** - runtime theme

- **Starship** - `~/.config/starship.toml`
- **Fish** - shell colors
- **Zsh** - Via GTK theme

- **Waybar** - `~/.config/waybar/style.css`
- **Rofi** - `~/.config/rofi/config.rasi`
- **Mako** - `~/.config/mako/colors`
- **SwayNC** - `~/.config/swaync/matugen/colors.css`
- **Hyprland** - `~/.config/hypr/theme/colors.conf`
- **Fuzzel** - launcher
- **Wofi** - launcher
- **Kanshi** - display config
- **Sway** - X11 fallback
- **SwayLock** - screensaver
- **nwg-look** - GTK manager
- **Geary** - sh3rb1n1@gmail.com

- **GTK3** - `~/.config/gtk-3.0/gtk.css`
- **GTK4** - `~/.config/gtk-4.0/gtk.css`
- **Qt5** - qt5ct
- **Qt6** - qt6ct

- **btop** - `~/.config/btop/themes/`
- **Cava** - audio visualizer
- **Fastfetch** - system info

- **mpd/rmpc** - `~/.config/rmpc/`
- **Vesktop** - `~/.config/vesktop/`
- **Spotify** - Spicetify
- **Discord** - app

- **Yazi** - `~/.config/yazi/`
- **Nautilus** - GTK file manager

- **Neovim** - uses GTK colors
- **VS Code** - `~/.config/Code/User/settings.json`
- **Obsidian** - notes
- **lazygit** - git UI

- **Firefox** - `~/.mozilla/firefox/*/chrome/colors.css`
- **Brave** - `~/.config/BraveSoftware/`
- **Chromium** - Uses system theme

- **KDE Connect** - device integration
- **Typora** - markdown editor


```
~/.config/catbug0x1/
├── catbug0x1           # Main CLI tool
├── hooks/             # Theme hook scripts
│   ├── 01-gtk.sh    # Main hook (GTK, Qt, Waybar, Rofi, Mako, SwayNC, Hyprland)
│   ├── 00-*.sh      # Terminal hooks (Alacritty, Ghostty, Kitty)
│   └── 40-*.sh     # App hooks (Obsidian, Pywalfox)
├── themes/           # Theme definitions (symlink to dotfiles/themes/)
└── .current-theme   # Current theme name file

~/.config/hypr/scripts/theme/
├── sync-all         # Full system sync
├── verify          # Theme verification
├── engine          # Theme CLI
└── auto-switch    # Time-based auto switching
```


Hooks run in order when `catbug0x1 switch` executes:

1. `00-*.sh` - Terminal emulators
2. `01-gtk.sh` - Core system (GTK, Qt, Waybar, Mako, SwayNC, Hyprland, Firefox, VS Code)
3. `10-*.sh` - Desktop components
4. `20-*.sh` - System monitors
5. `30-*.sh` - Media players
6. `40-*.sh` - Editors/browsers
7. `50-*.sh` - Additional apps


Each theme contains `.config/` subdirectories:

```
<theme>/.config/
├── gtk-3.0/colors.css     # GTK3 colors (@define-color)
├── gtk-4.0/colors.css   # GTK4 colors
├── hypr/theme/colors.conf  # Hyprland border colors
├── waybar/colors.css    # Waybar accent colors
├── rofi/config.rasi    # Rofi configuration
├── mako/colors        # Mako notification colors
├── swaync/matugen/colors.css  # SwayNC colors
├── alacritty/         # Alacritty theme
├── kitty/             # Kitty theme
├── ghostty/           # Ghostty theme
├── starship.toml      # Starship prompt
├── btop/             # btop theme
├── cava/             # Cava config
├── rmpc/             # rmpc theme
├── vesktop/           # Vesktop theme
├── yazi/             # Yazi theme
├── nvim/             # Neovim colors
└── Code/User/settings.json  # VS Code settings
```


catbug0x1 sets these for applications:

```bash
CATBUG0X1_THEME=<theme-name>
CATBUG0X1_DIR=~/.config/catbug0x1
GTK_THEME=<theme-name>
```



1. Check if hook exists: `ls ~/.config/catbug0x1/hooks/`
2. Check theme has config: `ls ~/.config/catbug0x1/<theme>/.config/`
3. Verify application config: `ls ~/.config/<app>/`
4. Run manual sync: `~/.config/hypr/scripts/theme/sync-all`


1. Check source colors: `cat ~/.config/catbug0x1/<theme>/.config/gtk-3.0/colors.css`
2. Check merged file: `cat ~/.config/gtk-3.0/gtk.css`
3. Restart application


1. Check settings: `cat ~/.config/gtk-3.0/settings.ini`
2. Run nwg-look: `nwg-look -s <theme-name>`


1. Check qt5ct: `cat ~/.config/qt5ct/qt5ct.conf`
2. Check qt6ct: `cat ~/.config/qt6ct/qt6ct.conf`


1. Check colors: `cat ~/.config/waybar/style.css`
2. Restart waybar: `pkill waybar && uwsm-app -- waybar &`
