#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh" 2>/dev/null || {
    NO_COLOR='\033[0m' RED='\033[0;31m' GRN='\033[0;32m' YEL='\033[1;33m' CYN='\033[0;36m' DIM='\033[2m'
}

declare -A CATEGORIES=(
  [media]="Audio & Media"
  [system]="System & Power"
  [theme]="Theme & Wallpaper"
  [ui]="User Interface"
  [root]="Other"
)

declare -A SCRIPTS=(
  ["media/audio-switch"]="Switch audio output"
  ["system/battery-notify"]="Battery monitoring"
  ["screenrecord"]="Screen recording"
  ["screenshot"]="Screenshot tool"
  ["nightlight"]="Nightlight filter"
  
  ["system/graceful-reboot"]="Clean reboot"
  ["system/graceful-shutdown"]="Clean shutdown"
  ["restart-app"]="Restart application"
  ["toggle-monitor"]="Toggle monitor"
  ["toggle-idle"]="Toggle idle lock"
  
  ["theme/change-theme"]="Change dynamic theme"
  ["theme/cycle-wallpaper"]="Cycle wallpapers"
  
  ["focus"]="Focus/launch window"
  ["pop-window"]="Pop out window"
  ["toggle-focus"]="Focus/Vibe mode"
  ["toggle-waybar"]="Toggle waybar"
  ["toggle-terminal-transparency"]="Terminal opacity"
  
  ["lock-screen"]="Lock screen"
  ["launch-browser"]="Launch browser"
  ["launch-webapp"]="Launch webapp"
  ["webapp-install"]="Install webapp"
  ["webapp-remove"]="Remove webapp"
  ["fileshare"]="File sharing"
  ["first-run"]="First run setup"
  ["cwd-terminal"]="Get terminal CWD"
)

usage() {
  cat << EOF
${CYN}╔════════════════════════════════════════════════════════════════╗${NO_COLOR}
${CYN}║           HYPRLAND SCRIPTS MANAGER v2.0                      ║${NO_COLOR}
${CYN}╚════════════════════════════════════════════════════════════════╝${NO_COLOR}

${GRN}USAGE:${NO_COLOR}
  scripts.sh [COMMAND] [OPTIONS]

${GRN}COMMANDS:${NO_COLOR}
  ${YEL}list${NO_COLOR} [category]     List all scripts or by category
  ${YEL}run${NO_COLOR} <script>        Run a specific script
  ${YEL}info${NO_COLOR} <script>       Show script information
  ${YEL}path${NO_COLOR} <script>       Show script path
  ${YEL}edit${NO_COLOR} <script>       Edit script with nvim
  ${YEL}help${NO_COLOR}                Show this help message

${GRN}CATEGORIES:${NO_COLOR}
  ${YEL}media${NO_COLOR}   - Audio, video, screenshots
  ${YEL}system${NO_COLOR}  - Power, restart, monitors
  ${YEL}theme${NO_COLOR}   - Wallpapers, themes
  ${YEL}ui${NO_COLOR}      - Window management, UI

${GRN}EXAMPLES:${NO_COLOR}
  scripts.sh list              # List all scripts
  scripts.sh list media        # List media scripts
  scripts.sh run screenshot    # Take screenshot
  scripts.sh edit lock-screen  # Edit lock screen

EOF
}

list_scripts() {
  local filter="${1:-}"
  local count=0
  
  echo ""
  echo -e "${CYN}╔════════════════════════════════════════════════════════════════╗${NO_COLOR}"
  echo -e "${CYN}║                    AVAILABLE SCRIPTS                             ║${NO_COLOR}"
  echo -e "${CYN}╚════════════════════════════════════════════════════════════════╝${NO_COLOR}"
  echo ""
  
  for cat in media system theme ui root; do
    local catname="${CATEGORIES[$cat]:-}"
    [[ -z "$catname" ]] && catname="Other"
    local printed_header=0
    
    for script in "${!SCRIPTS[@]}"; do
      if [[ "$cat" == "root" ]]; then
        [[ "$script" == */* ]] && continue
      else
        [[ "$script" == "${cat}/"* ]] || continue
      fi
      
      if [[ -n "$filter" && "$script" != *"$filter"* ]]; then
        continue
      fi
      
      if [[ $printed_header -eq 0 ]]; then
        echo -e "  ${YEL}▸ $catname${NO_COLOR}"
        printed_header=1
      fi
      
      local path=""
      if [[ -x "$SCRIPT_DIR/$script" ]]; then
        path="$SCRIPT_DIR/$script"
      elif [[ "$script" != */* && -x "$SCRIPT_DIR/${script}" ]]; then
        path="$SCRIPT_DIR/${script}"
      fi
      local status="  "
      [[ -n "$path" && -x "$path" ]] && status="${GRN}✓${NO_COLOR} " || status="${RED}✗${NO_COLOR} "
      
      printf "    ${status}%-30s ${DIM}→${NO_COLOR} %s\n" "$(basename "$script")" "${SCRIPTS[$script]}"
      ((count++))
    done
    
    [[ $printed_header -eq 1 ]] && echo ""
  done
  
  echo -e "  ${DIM}Total: $count scripts${NO_COLOR}"
  echo ""
}

run_script() {
  local script="$1"
  [[ -z "$script" ]] && { err "Usage: scripts.sh run <script>"; return 1; }
  
  local path="$SCRIPT_DIR/$script"
  [[ ! -f "$path" ]] && path="$SCRIPT_DIR/${script#scripts/}"
  
  if [[ ! -f "$path" ]]; then
    err "Script not found: $script"
    return 1
  fi
  
  log "Running: $script"
  "$path" "${@:2}"
}

script_info() {
  local script="$1"
  [[ -z "$script" ]] && { err "Usage: scripts.sh info <script>"; return 1; }
  
  local path="$SCRIPT_DIR/$script"
  [[ ! -f "$path" ]] && path="$SCRIPT_DIR/${script#scripts/}"
  
  if [[ ! -f "$path" ]]; then
    err "Script not found: $script"
    return 1
  fi
  
  echo ""
  echo -e "${CYN}╔════════════════════════════════════════════════════════════════╗${NO_COLOR}"
  echo -e "${CYN}║${NO_COLOR}  $(basename "$script")${CYN}                                                      ║${NO_COLOR}"
  echo -e "${CYN}╚════════════════════════════════════════════════════════════════╝${NO_COLOR}"
  echo ""
  echo -e "  ${YEL}Path:${NO_COLOR}   $path"
  echo -e "  ${YEL}Size:${NO_COLOR}   $(wc -c < "$path") bytes | $(wc -l < "$path") lines"
  echo -e "  ${YEL}Perms:${NO_COLOR}  $(stat -c %a "$path")"
  echo -e "  ${YEL}Desc:${NO_COLOR}   ${SCRIPTS[$script]:-N/A}"
  echo ""
  
  if head -1 "$path" | grep -q "^#!/"; then
    local shebang=$(head -1 "$path")
    echo -e "  ${YEL}Type:${NO_COLOR}   $shebang"
  fi
  
  echo ""
}

main() {
  [[ -z "${1:-}" ]] && { usage; exit 0; }
  
  case "$1" in
    list|l) list_scripts "${2:-}";;
    run|r) run_script "${2:-}" "${@:3}";;
    info|i) script_info "${2:-}";;
    path) echo "$SCRIPT_DIR/${2:-}";;
    edit|e) "${EDITOR:-nvim}" "$SCRIPT_DIR/${2:-}";;
    help|h|--help|-h) usage;;
    *) err "Unknown command: $1"; usage; exit 1;;
  esac
}

main "$@"
