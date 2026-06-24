
Organized collection of utility scripts for Hyprland with a centralized management system.


```
scripts/
├── lib/
│   └── common.sh           # Shared utilities
├── media/
│   ├── audio-switch       # Switch audio output
│   ├── battery-notify     # Battery monitoring
│   ├── nightlight         # Blue light filter
│   ├── screenrecord       # Screen recording
│   └── screenshot         # Screenshot tool
├── system/
│   ├── graceful-reboot    # Clean reboot
│   ├── graceful-shutdown  # Clean shutdown
│   ├── restart-app        # Restart application
│   ├── toggle-idle       # Toggle idle lock
│   └── toggle-monitor    # Toggle monitor
├── theme/
│   ├── change-theme       # Dynamic theme
│   └── cycle-wallpaper   # Cycle wallpapers
├── ui/
│   ├── focus             # Focus/launch window
│   ├── pop-window        # Pop out window
│   ├── toggle-focus      # Focus/Vibe mode
│   ├── toggle-terminal-transparency
│   └── toggle-waybar     # Toggle waybar
├── fileshare             # File sharing
├── first-run            # First run setup
├── launch-browser       # Browser launcher
├── launch-webapp        # WebApp launcher
├── lock-screen          # Lock screen
├── scripts.sh           # Script manager
├── webapp-install      # Install webapp
└── webapp-remove       # Remove webapp
```


```bash
~/.config/hypr/scripts/scripts.sh list
```

```bash
~/.config/hypr/scripts/scripts.sh list media
~/.config/hypr/scripts/scripts.sh list system
~/.config/hypr/scripts/scripts.sh list theme
~/.config/hypr/scripts/scripts.sh list ui
```

```bash
~/.config/hypr/scripts/scripts.sh run screenshot
~/.config/hypr/scripts/scripts.sh run change-theme
```

```bash
~/.config/hypr/scripts/scripts.sh info screenshot
~/.config/hypr/scripts/scripts.sh path screenshot
```

```bash
~/.config/hypr/scripts/scripts.sh edit screenshot
```


Provides reusable functions:
- `log()`, `warn()`, `err()` - Logging
- `get_wallbin()` - Detect wallpaper daemon
- `get_focused_monitor()` - Get active monitor
- `notify()`, `notify_success()`, `notify_error()` - Notifications
- `require_cmd()` - Dependency checking
- `ensure_dir()`, `ensure_file()` - File helpers
- `acquire_lock()` - Single instance
- `confirm()` - Interactive confirmation


Include common.sh at the top of your scripts:

```bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

log "Starting my script..."
require_cmd jq || exit 1
notify_success "Done!"
```


| Action | Default Binding |
|--------|----------------|
| Screenshot | `SUPER + P` |
| Screen Record | `SUPER + R` |
| Lock Screen | `SUPER + SHIFT + L` |
| Toggle Waybar | `SUPER + SHIFT + SPACE` |
| Nightlight | `SUPER + CTRL + N` |
| Theme Switcher | `SUPER + CTRL + SHIFT + SPACE` |


| Package | Used By |
|--------|---------|
| jq | All scripts |
| grim | Screenshots |
| slurp | Region selection |
| satty | Screenshot editing |
| swww/awww | Wallpaper |
| matugen | Theme colors |
| rofi | Menus |
| waybar | Status bar |


- **2.0** (2026-04-15) - Organized into categories, added script manager
- **1.0** - Initial collection
