**Last Updated:** 2026-04-15

---


```bash
scripts.sh list

scripts.sh run screenshot

scripts.sh help
```

---


| Category | Scripts |
|----------|---------|
| **media** | audio-switch, battery-notify, nightlight, screenrecord, screenshot |
| **system** | graceful-reboot, graceful-shutdown, restart-app, toggle-idle, toggle-monitor |
| **theme** | change-theme, cycle-wallpaper |
| **ui** | focus, pop-window, toggle-focus, toggle-waybar, toggle-terminal-transparency |

---


```bash
log "Success message"      # [✓] green
warn "Warning message"    # [!] yellow  
err "Error message"       # [✗] red
```

```bash
notify "Message"
notify "Message" "icon" "urgency"
notify_success "Done!"
notify_error "Failed!" "battery-empty"
notify_warn "Warning"
```

```bash
require_cmd jq           # Check single command
require_cmds jq grim     # Check multiple commands
```

```bash
ensure_dir ~/.cache      # Create directory if missing
ensure_file ~/.config     # Create file if missing
is_file ~/.bashrc        # Check if file exists
is_dir ~/.config         # Check if directory exists
```

```bash
acquire_lock /tmp/my.lock  # Prevent multiple instances
```

```bash
confirm "Continue?"       # Ask yes/no
```

```bash
trim "  text  "           # Remove whitespace
tolower "TEXT"            # To lowercase
toupper "text"            # To uppercase
startswith "hello" "he"  # Check prefix
endswith "hello" "lo"    # Check suffix
```

```bash
contains "item" "${arr[@]}"  # Check if in array
join "," "${arr[@]}"         # Join with separator
```

```bash
timestamp                   # 2026-04-15 12:00:00
epoch                       # Unix timestamp
```

```bash
min 5 10                    # 5
max 5 10                     # 10
clamp 150 0 100             # 100
```

```bash
get_focused_monitor         # eDP-1
get_all_monitors           # List all monitors
hypr_active_window         # JSON of active window
hypr_workspaces           # JSON of workspaces
hypr_clients              # JSON of all clients
```

```bash
audio_sinks                 # List all sinks
audio_default_sink          # Current default sink
audio_set_sink "sink-name"  # Change default sink
audio_volume "sink-name"    # Get sink volume
```

```bash
wifi_list                  # List WiFi networks
wifi_connected             # Check if connected
```

```bash
get_wallbin                # Returns: swww or awww
ensure_wallpaper_daemon    # Start daemon if needed
```

---


```bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

log "Starting..."
require_cmd jq grim || exit 1
notify_success "Done!"
```

---


| Action | Binding | Script |
|--------|---------|--------|
| Screenshot | `SUPER + P` | screenshot |
| Screen Record | `SUPER + R` | screenrecord |
| Lock Screen | `SUPER + SHIFT + L` | lock-screen |
| Toggle Waybar | `SUPER + SHIFT + SPACE` | toggle-waybar |
| Nightlight | `SUPER + CTRL + N` | nightlight |
| Theme Picker | `SUPER + CTRL + SPACE` | selectWall |
| WiFi Menu | `SUPER + SHIFT + N` | wifi |
| Power Menu | `SUPER + ESCAPE` | powermenu |

---


| Package | Used By |
|---------|--------|
| jq | All scripts |
| grim | Screenshots |
| slurp | Region selection |
| satty | Screenshot editing |
| swww/awww | Wallpaper |
| matugen | Theme colors |
| rofi | Menus |
| waybar | Status bar |
| cliphist | Clipboard |
| wl-clipboard | Clipboard |
| pactl | Audio |
| nmcli | WiFi |
| ddcutil | Monitor |
| powerprofilesctl | Power |
| gpu-screen-recorder | Recording |
