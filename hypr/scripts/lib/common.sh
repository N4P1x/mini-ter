#!/bin/bash
[[ -n "${_COMMON_SH:-}" ]] && return 0
readonly _COMMON_SH=1

# Source environment paths
source "${BASH_SOURCE[0]%/*}/../../../N4P1x/env.sh" 2>/dev/null || true

NO_COLOR='\033[0m'
RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[0;34m'
CYN='\033[0;36m'
DIM='\033[2m'

log() { printf "${GRN}[✓]${NO_COLOR} %s\n" "$1"; }
warn() { printf "${YEL}[!]${NO_COLOR} %s\n" "$1" >&2; }
err() { printf "${RED}[✗]${NO_COLOR} %s\n" "$1" >&2; }

get_wallbin() { command -v swww >/dev/null && echo swww || command -v awww >/dev/null && echo awww || return 1; }
ensure_wallpaper_daemon() { local b; b=$(get_wallbin) || return 1; "$b" query &>/dev/null || "$b"-daemon --format xrgb; echo "$b"; }

get_focused_monitor() { hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true).name // empty' || echo ""; }
get_all_monitors() { hyprctl monitors -j 2>/dev/null | jq -r '.[].name' || echo ""; }

notify() {
    if [[ -n "${2:-}" ]]; then
        notify-send -u "${3:-normal}" -i "$2" "$1"
    else
        notify-send -u "${3:-normal}" "$1"
    fi
}
notify_success() { notify "$1" "${2:-}" "normal"; }
notify_error() { notify "$1" "${2:-}" "critical"; }
notify_warn() { notify "$1" "${2:-}" "normal"; }

require_cmd() { command -v "$1" >/dev/null 2>&1 || { err "Missing: $1"; return 1; }; }
require_cmds() { for c in "$@"; do require_cmd "$c" || return 1; done; }

ensure_dir() { [[ -d "$1" ]] || mkdir -p "$1"; }
ensure_file() { [[ -f "$1" ]] || touch "$1"; }
is_file() { [[ -f "$1" ]]; }
is_dir() { [[ -d "$1" ]]; }
file_exists() { [[ -e "$1" ]]; }

acquire_lock() { exec 200>"$1"; flock -n 200 || exit 0; }

confirm() { read -rp "$1 [y/N] " -n 1 && echo && [[ $REPLY =~ ^[Yy]$ ]]; }

trim() { local v="$1"; v="${v#"${v%%[![:space:]]*}"}"; v="${v%"${v##*[![:space:]]}"}"; echo "$v"; }
tolower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }
toupper() { echo "$1" | tr '[:lower:]' '[:upper:]'; }
startswith() { [[ "$1" == "$2"* ]]; }
endswith() { [[ "$1" == *"$2" ]]; }

contains() { local item="$1"; shift; for i in "$@"; do [[ "$i" == "$item" ]] && return 0; done; return 1; }
join() { local IFS="$1"; shift; echo "$*"; }

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
epoch() { date '+%s'; }

min() { echo $(( $1 < $2 ? $1 : $2 )); }
max() { echo $(( $1 > $2 ? $1 : $2 )); }
clamp() { echo $(( $1 < $2 ? $2 : ($1 > $3 ? $3 : $1) )); }

hypr_active_window() { hyprctl activewindow -j 2>/dev/null; }
hypr_workspaces() { hyprctl workspaces -j 2>/dev/null; }
hypr_clients() { hyprctl clients -j 2>/dev/null; }

audio_sinks() { pactl -f json list sinks 2>/dev/null | jq -r '.[].name'; }
audio_default_sink() { pactl get-default-sink 2>/dev/null; }
audio_set_sink() { pactl set-default-sink "$1" 2>/dev/null; }
audio_volume() { pactl get-sink-volume "$1" 2>/dev/null | jq -r '.[0]'; }

wifi_list() { nmcli -t -f SSID,BARS device wifi list 2>/dev/null; }
wifi_connected() { nmcli -t -f STATE device wifi 2>/dev/null | grep -q "connected"; }
