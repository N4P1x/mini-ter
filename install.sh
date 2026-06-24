#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# mini-ter Installer – Arch Linux Rice Setup
# ──────────────────────────────────────────────────────────────────────────────

# ---- Metadata ----
VERSION="2.0.0"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_TARGET="${HOME}/.config"
LOG_FILE="/tmp/mini-ter-install-$(date +%s).log"
TITLE="mini-ter v${VERSION}"

# ---- Colors ----
R="\033[1;31m" G="\033[1;32m" Y="\033[1;33m" B="\033[1;34m" C="\033[1;36m"
M="\033[1;35m" W="\033[1;37m" N="\033[0m"

# ---- State ----
COMPOSITOR=""
TERMINAL=""
INSTALL_GROUPS=()
OPTIONS_CHOSEN=false
USE_GUM=false
USE_DIALOG=false

# ──────────────────────────────────────────────────────────────────────────────
# HELPERS
# ──────────────────────────────────────────────────────────────────────────────

log()  { echo -e "${G}[+]${N} $*" | tee -a "$LOG_FILE"; }
warn() { echo -e "${Y}[!]${N} $*" | tee -a "$LOG_FILE"; }
err()  { echo -e "${R}[-]${N} $*" | tee -a "$LOG_FILE"; }
head() { echo -e "\n${B}━━━ $* ━━━${N}\n"; }
cmd()  { echo -e "${C}\$ $*${N}" >> "$LOG_FILE"; "$@" 2>&1 | tee -a "$LOG_FILE"; }

cleanup() { rm -f /tmp/mini-ter-*.tmp; }
trap cleanup EXIT

# ──────────────────────────────────────────────────────────────────────────────
# TUI DETECTION
# ──────────────────────────────────────────────────────────────────────────────

detect_tui() {
    if command -v gum &>/dev/null; then
        USE_GUM=true
    elif command -v whiptail &>/dev/null; then
        USE_DIALOG=true
    fi
}

gum_yn() {
    gum confirm "$1" --default="$2" --affirmative="Yes" --negative="No" && return 0 || return 1
}

gum_pick() {
    local prompt="$1"; shift
    gum choose --header "$prompt" --cursor="▶ " --height=15 "$@"
}

gum_multi() {
    local prompt="$1"; shift
    gum choose --header "$prompt" --cursor="▶ " --no-limit --height=20 "$@"
}

pick() {
    if $USE_GUM; then gum_pick "$@"; else shift; echo "$1"; fi
}

pick_multi() {
    if $USE_GUM; then gum_multi "$@"; else shift; echo "$1"; fi
}

confirm() {
    if $USE_GUM; then gum_yn "$1" "${2:-true}"; return $?; fi
    local dflt="${2:-true}"
    local prompt_str
    if [[ "$dflt" == "true" ]]; then prompt_str="[Y/n]"; else prompt_str="[y/N]"; fi
    read -r -p "$1 $prompt_str " ans
    ans="${ans,,}"
    if [[ "$dflt" == "true" ]]; then
        [[ "$ans" =~ ^(y|yes|)$ ]] && return 0 || return 1
    else
        [[ "$ans" =~ ^(y|yes) ]] && return 0 || return 1
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# SYSTEM DETECTION
# ──────────────────────────────────────────────────────────────────────────────

detect_system() {
    if [[ ! -f /etc/arch-release ]]; then
        warn "Not running Arch Linux. Some packages may differ."
        confirm "Continue anyway?" false || exit 1
    fi

    if [[ -z "${WAYLAND_DISPLAY:-}" && ! -f /run/.wayland-* ]]; then
        warn "Wayland session not detected."
        confirm "Continue anyway?" || true
    fi

    GPU_VENDOR="unknown"
    if lspci 2>/dev/null | grep -qi "nvidia"; then
        GPU_VENDOR="nvidia"
    elif lspci 2>/dev/null | grep -qi "intel.*graphics\|hd graphics"; then
        GPU_VENDOR="intel"
    elif lspci 2>/dev/null | grep -qi "amd.*graphics\|radeon"; then
        GPU_VENDOR="amd"
    fi

    HAS_SYSTEMD=$(command -v systemctl &>/dev/null && echo true || echo false)
    HAS_PARU=$(command -v paru &>/dev/null && echo true || echo false)
    HAS_YAY=$(command -v yay &>/dev/null && echo true || echo false)
    AUR_HELPER="pacman"
    if $HAS_PARU; then AUR_HELPER="paru"
    elif $HAS_YAY; then AUR_HELPER="yay"; fi
}

# ──────────────────────────────────────────────────────────────────────────────
# PACKAGE DEFINITIONS
# ──────────────────────────────────────────────────────────────────────────────

CORE_PACKAGES=(
    # WM / Compositor
    "hyprland" "hyprlock" "hypridle" "hyprsunset" "xdg-desktop-portal-hyprland"
    # UI
    "waybar" "rofi-lbonn-wayland" "mako" "swaynotificationcenter"
    # Shell
    "fish" "starship" "fzf" "zoxide" "eza"
    # Terminals
    "ghostty" "kitty" "alacritty"
    # Utilities
    "swaylock" "swayidle" "swayosd" "swaync" "swaybg"
    "cliphist" "wl-clipboard" "grim" "slurp" "satty"
    "brightnessctl" "playerctl" "pavucontrol"
    "jq" "dbus" "gum" "polkit-gnome"
    "kdeconnect" "kanshi" "nwg-look"
    # Fonts
    "ttf-jetbrains-mono" "ttf-nerd-fonts-symbols" "ttf-nerd-fonts-symbols-mono"
    "ttf-inter" "otf-sf-pro" "ttf-cascadia-code-nerd"
    # Icons / Cursor
    "papirus-icon-theme" "bibata-cursor-theme"
    # Monitoring
    "btop" "fastfetch"
    # Audio
    "pipewire" "pipewire-pulse" "wireplumber" "pamixer"
    # Theming
    "matugen" "python-material-color-utilities"
)

OPTIONAL_PACKAGES=(
    # Editors
    "neovim" "python-pynvim" "code" "vscodium-bin"
    # Git / Dev
    "git" "github-cli" "lazygit" "docker" "docker-compose"
    "go" "flutter" "android-tools"
    # Web
    "brave-bin" "chromium" "zen-browser"
    # Media
    "mpd" "mpd-mpris" "rmpc" "mpdscribble" "cava"
    "mpv" "sonic-visualiser" "spicetify-cli"
    # Security / CTF
    "feroxbuster" "ffuf" "jadx" "openstego" "sigrok-cli" "pulseview"
    # File managers
    "yazi" "nnn" "thunar" "pcmanfm"
    # Misc
    "obsidian" "typora" "geary" "vesktop" "onlyoffice-bin"
    "tmux" "jrnl" "okular"
)

# Flattened for install
ALL_PACKAGES=("${CORE_PACKAGES[@]}" "${OPTIONAL_PACKAGES[@]}")

declare -A PKG_DESC
PKG_DESC[hyprland]="Wayland compositor"
PKG_DESC[waybar]="Status bar"
PKG_DESC[rofi-lbonn-wayland]="Application launcher"
PKG_DESC[mako]="Notification daemon"
PKG_DESC[swaynotificationcenter]="Notification center"
PKG_DESC[fish]="Shell"
PKG_DESC[starship]="Prompt"
PKG_DESC[fzf]="Fuzzy finder"
PKG_DESC[zoxide]="Smart directory jumper"
PKG_DESC[eza]="Modern ls replacement"
PKG_DESC[ghostty]="GPU-accelerated terminal"
PKG_DESC[kitty]="Terminal emulator"
PKG_DESC[alacritty]="GPU-accelerated terminal"
PKG_DESC[cliphist]="Clipboard manager"
PKG_DESC[grim]="Screenshot tool"
PKG_DESC[slurp]="Region selection"
PKG_DESC[satty]="Screenshot annotation"
PKG_DESC[gum]="TUI toolkit (used by installer)"
PKG_DESC[matugen]="Material You color generator"
PKG_DESC[btop]="System monitor"
PKG_DESC[fastfetch]="System info fetch"
PKG_DESC[cava]="Audio visualizer"
PKG_DESC[neovim]="Code editor"
PKG_DESC[yazi]="Terminal file manager"
PKG_DESC[tmux]="Terminal multiplexer"
PKG_DESC[spicetify-cli]="Spotify theming"
PKG_DESC[feroxbuster]="Web directory brute-forcer"
PKG_DESC[ffuf]="Web fuzzer"
PKG_DESC[jadx]="Android/Java decompiler"
PKG_DESC[openstego]="Steganography tool"
PKG_DESC[sigrok-cli]="Logic analyzer"
PKG_DESC[vesktop]="Discord client"
PKG_DESC[papirus-icon-theme]="Icon theme"
PKG_DESC[bibata-cursor-theme]="Cursor theme"

# ──────────────────────────────────────────────────────────────────────────────
# COMPONENT GROUPS
# ──────────────────────────────────────────────────────────────────────────────

declare -A GROUP_PKGS
GROUP_PKGS["core"]="${CORE_PACKAGES[*]}"
GROUP_PKGS["editors"]="neovim python-pynvim code vscodium-bin"
GROUP_PKGS["dev"]="git github-cli lazygit docker docker-compose go flutter android-tools"
GROUP_PKGS["browsers"]="brave-bin chromium zen-browser"
GROUP_PKGS["media"]="mpd rmpc mpdscribble cava mpv sonic-visualiser spicetify-cli"
GROUP_PKGS["ctf"]="feroxbuster ffuf jadx openstego sigrok-cli pulseview"
GROUP_PKGS["files"]="yazi nnn thunar pcmanfm"
GROUP_PKGS["misc"]="obsidian typora geary vesktop onlyoffice-bin tmux jrnl okular"

declare -A GROUP_DESC
GROUP_DESC["core"]="Core desktop environment (required)"
GROUP_DESC["editors"]="Code editors (Neovim, VS Code, VSCodium)"
GROUP_DESC["dev"]="Development tools (Docker, Go, Flutter, Git)"
GROUP_DESC["browsers"]="Web browsers (Brave, Chromium, Zen)"
GROUP_DESC["media"]="Media & music (MPD, cava, spicetify, mpv)"
GROUP_DESC["ctf"]="Security & CTF tools (feroxbuster, ffuf, jadx)"
GROUP_DESC["files"]="File managers (Yazi, nnn, Thunar)"
GROUP_DESC["misc"]="Other applications (Obsidian, Vesktop, tmux)"

# ──────────────────────────────────────────────────────────────────────────────
# BANNER
# ──────────────────────────────────────────────────────────────────────────────

show_banner() {
    clear
    echo -e "${M}"
    cat << "EOF"
 ___      ___   __    _____  ___    __  ___________  _______   _______   
|"  \    /"  | |" \  (\"   \|"  \  |" \("     _   ")/"     "| /"      \  
 \   \  //   | ||  | |.\\   \    | ||  |)__/  \\__/(: ______)|:        | 
 /\\  \/.    | |:  | |: \.   \\  | |:  |   \\_ /    \/    |  |_____/   ) 
|: \.        | |.  | |.  \    \. | |.  |   |.  |    // ___)_  //      /  
|.  \    /:  | /\  |\|    \    \ | /\  |\  \:  |   (:      "||:  __   \  
|___|\__/|___|(__\_|_)\___|\____\)(__\_|_)  \__|    \_______)|__|  \___) 
                                                                         
EOF
    echo -e "${N}"
    echo -e "  ${W}mini-ter v${VERSION} — Arch Linux Rice Installer${N}"
    echo -e "  ${Y}N4P1x · Material You · Hyprland${N}"
    echo -e "  ${C}https://github.com/N4P1x/mini-ter${N}\n"
    echo -e "  ${W}This installer will guide you through setting up the${N}"
    echo -e "  ${W}complete mini-ter desktop environment on your system.${N}\n"
}

# ──────────────────────────────────────────────────────────────────────────────
# MENU
# ──────────────────────────────────────────────────────────────────────────────

menu_main() {
    if $USE_GUM; then
        gum_yn "Ready to start the installation?" true || exit 0
        return
    fi
    echo "This installer will guide you through setting up mini-ter."
    echo "It will install packages, deploy configs, and run the theme engine."
    echo ""
    confirm "Ready to start?" true || exit 0
}

select_compositor() {
    head "Select Compositor"
    local opts=("hyprland" "sway" "niri")
    local picked
    if $USE_GUM; then
        picked=$(gum_pick "Choose your Wayland compositor:" "${opts[@]}")
    else
        echo "1) hyprland (recommended)"
        echo "2) sway"
        echo "3) niri"
        read -r -p "Choice [1]: " sel
        sel="${sel:-1}"
        case "$sel" in
            1) picked="hyprland" ;;
            2) picked="sway" ;;
            3) picked="niri" ;;
            *) picked="hyprland" ;;
        esac
    fi
    COMPOSITOR="$picked"
    log "Compositor: $COMPOSITOR"
}

select_terminal() {
    head "Select Terminal"
    local opts=("ghostty" "kitty" "alacritty")
    local picked
    if $USE_GUM; then
        picked=$(gum_pick "Choose your primary terminal:" "${opts[@]}")
    else
        echo "1) ghostty (recommended — GPU accelerated)"
        echo "2) kitty"
        echo "3) alacritty"
        read -r -p "Choice [1]: " sel
        sel="${sel:-1}"
        case "$sel" in
            1) picked="ghostty" ;;
            2) picked="kitty" ;;
            3) picked="alacritty" ;;
            *) picked="ghostty" ;;
        esac
    fi
    TERMINAL="$picked"
    log "Terminal: $TERMINAL"
}

select_components() {
    head "Select Component Groups"
    local groups=()
    for key in "${!GROUP_DESC[@]}"; do
        groups+=("$key" "${GROUP_DESC[$key]}")
    done

    local chosen
    if $USE_GUM; then
        # gum multi-select
        local opts=()
        for key in "${!GROUP_DESC[@]}"; do
            opts+=("$key: ${GROUP_DESC[$key]}")
        done
        chosen=$(gum_multi "Select groups to install (space to toggle):" "${opts[@]}")
        # Parse back to keys
        INSTALL_GROUPS=()
        while IFS= read -r line; do
            INSTALL_GROUPS+=("${line%%:*}")
        done <<< "$chosen"
    else
        echo ""
        for key in "${!GROUP_DESC[@]}"; do
            local dflt=true
            [[ "$key" == "core" ]] && dflt=true || dflt=true
            if confirm "Install ${GROUP_DESC[$key]}?" "$dflt"; then
                INSTALL_GROUPS+=("$key")
            fi
        done
    fi

    # Ensure core is always included
    if [[ ! " ${INSTALL_GROUPS[*]} " =~ " core " ]]; then
        INSTALL_GROUPS=("core" "${INSTALL_GROUPS[@]}")
    fi

    log "Selected groups: ${INSTALL_GROUPS[*]}"
}

# ──────────────────────────────────────────────────────────────────────────────
# PACKAGE RESOLUTION
# ──────────────────────────────────────────────────────────────────────────────

resolve_packages() {
    local pkgs=()

    for group in "${INSTALL_GROUPS[@]}"; do
        read -ra group_pkgs <<< "${GROUP_PKGS[$group]}"
        for pkg in "${group_pkgs[@]}"; do
            pkgs+=("$pkg")
        done
    done

    # Filter by compositor
    if [[ "$COMPOSITOR" != "hyprland" ]]; then
        pkgs=("${pkgs[@]/hyprland/}")
        pkgs=("${pkgs[@]/hyprlock/}")
        pkgs=("${pkgs[@]/hypridle/}")
        pkgs=("${pkgs[@]/hyprsunset/}")
        pkgs=("${pkgs[@]/xdg-desktop-portal-hyprland/}")
    fi

    # Only keep selected terminal
    for t in "ghostty" "kitty" "alacritty"; do
        [[ "$t" != "$TERMINAL" ]] && pkgs=("${pkgs[@]/$t/}")
    done

    # Remove empty entries
    local cleaned=()
    for p in "${pkgs[@]}"; do
        [[ -n "$p" ]] && cleaned+=("$p")
    done

    # De-duplicate
    mapfile -t INSTALL_PKGS < <(printf "%s\n" "${cleaned[@]}" | sort -u)

    # Separate AUR packages
    AUR_PKGS=()
    for pkg in "${INSTALL_PKGS[@]}"; do
        if [[ "$pkg" == *"-bin" || "$pkg" == *"-git" || "$pkg" == "python-material-color-utilities" \
           || "$pkg" == "matugen" || "$pkg" == "rofi-lbonn-wayland" \
           || "$pkg" == "bibata-cursor-theme" || "$pkg" == "otf-sf-pro" \
           || "$pkg" == "satty" || "$pkg" == "swayosd" \
           || "$pkg" == "spicetify-cli" || "$pkg" == "rmpc" \
           || "$pkg" == "vscodium-bin" || "$pkg" == "brave-bin" \
           || "$pkg" == "zen-browser" || "$pkg" == "vesktop" \
           || "$pkg" == "onlyoffice-bin" || "$pkg" == "ttf-cascadia-code-nerd" ]]; then
            AUR_PKGS+=("$pkg")
        fi
    done

    # Separate official packages
    OFFICIAL_PKGS=()
    for pkg in "${INSTALL_PKGS[@]}"; do
        if ! [[ " ${AUR_PKGS[*]} " =~ " $pkg " ]]; then
            OFFICIAL_PKGS+=("$pkg")
        fi
    done

    log "Official packages: ${#OFFICIAL_PKGS[@]}"
    log "AUR packages: ${#AUR_PKGS[@]}"
}

# ──────────────────────────────────────────────────────────────────────────────
# INSTALLATION
# ──────────────────────────────────────────────────────────────────────────────

install_packages() {
    if [[ ${#OFFICIAL_PKGS[@]} -eq 0 && ${#AUR_PKGS[@]} -eq 0 ]]; then
        log "No packages to install."
        return
    fi

    head "Package Installation"

    confirm "Install ${#OFFICIAL_PKGS[@]} official + ${#AUR_PKGS[@]} AUR packages?" true || return

    # Install official packages
    if [[ ${#OFFICIAL_PKGS[@]} -gt 0 ]]; then
        log "Installing official packages via pacman..."
        if $HAS_SYSTEMD; then
            cmd sudo pacman -S --needed --noconfirm "${OFFICIAL_PKGS[@]}"
        else
            err "pacman not available. Install manually:"
            echo "  sudo pacman -S ${OFFICIAL_PKGS[*]}"
            return 1
        fi
    fi

    # Install AUR packages
    if [[ ${#AUR_PKGS[@]} -gt 0 ]]; then
        log "Installing AUR packages via $AUR_HELPER..."
        case "$AUR_HELPER" in
            paru) cmd paru -S --needed --noconfirm "${AUR_PKGS[@]}" ;;
            yay)  cmd yay -S --needed --noconfirm "${AUR_PKGS[@]}" ;;
            *)
                warn "No AUR helper found. AUR packages to install manually:"
                printf "  %s\n" "${AUR_PKGS[@]}"
                ;;
        esac
    fi

    log "Package installation complete."
}

# ──────────────────────────────────────────────────────────────────────────────
# CONFIG DEPLOYMENT
# ──────────────────────────────────────────────────────────────────────────────

deploy_configs() {
    head "Deploying Configuration Files"

    if [[ "$REPO_DIR" == "$CONFIG_TARGET" ]]; then
        log "Already installed in ~/.config. Skipping copy."
        return
    fi

    # Backup existing config
    if [[ -d "$CONFIG_TARGET" && -n "$(ls -A "$CONFIG_TARGET" 2>/dev/null)" ]]; then
        local backup="${CONFIG_TARGET}.bak-$(date +%Y%m%d-%H%M%S)"
        warn "Backing up existing ~/.config to $backup"
        cmd cp -r "$CONFIG_TARGET" "$backup"
    fi

    log "Copying config files to $CONFIG_TARGET..."
    cmd cp -r "$REPO_DIR" "$CONFIG_TARGET"

    # Fix ownership
    cmd chown -R "$USER:$USER" "$CONFIG_TARGET"

    # Create required directories
    mkdir -p "$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME/Music/mpd" "$HOME/Music/Playlists"
    mkdir -p "$HOME/.local/share/jrnl"

    log "Config deployment complete."
}

# ──────────────────────────────────────────────────────────────────────────────
# COMPOSITOR-SPECIFIC SETUP
# ──────────────────────────────────────────────────────────────────────────────

setup_compositor() {
    head "Configuring $COMPOSITOR"

    case "$COMPOSITOR" in
        hyprland)
            # Ensure the main compositor config is active
            if [[ -f "$CONFIG_TARGET/hypr/hyprland.conf" ]]; then
                log "Hyprland config found."
            fi

            # xdg-desktop-portal
            if command -v /usr/lib/xdg-desktop-portal-hyprland &>/dev/null; then
                log "Setting up xdg-desktop-portal..."
                cmd systemctl --user enable --now xdg-desktop-portal-hyprland 2>/dev/null || true
            fi

            # Waybar (systemd user service)
            if [[ -f "$CONFIG_TARGET/systemd/user/waybar.service" ]]; then
                cmd systemctl --user enable waybar.service 2>/dev/null || true
            fi

            # Theme daemon
            if [[ -f "$CONFIG_TARGET/systemd/user/theme-daemon.service" ]]; then
                cmd systemctl --user enable theme-daemon.service 2>/dev/null || true
            fi

            # Performance service
            if [[ -f "$CONFIG_TARGET/systemd/user/performance.service" ]]; then
                cmd systemctl --user enable performance.service 2>/dev/null || true
            fi
            ;;

        sway)
            log "Sway config ready at $CONFIG_TARGET/sway/config"
            warn "Sway does not support N4P1x color sync natively."
            warn "Waybar and mako will still be themed."
            ;;

        niri)
            log "Niri config ready at $CONFIG_TARGET/niri/config.kdl"
            warn "Niri has its own keybinding set. See documentation."
            ;;
    esac

    log "Compositor setup complete."
}

# ──────────────────────────────────────────────────────────────────────────────
# THEME ENGINE SETUP
# ──────────────────────────────────────────────────────────────────────────────

setup_theme_engine() {
    head "Setting Up Theme Engine (N4P1x)"

    # Symlink hypr/ → N4P1x (if not already)
    local hypr_link="$CONFIG_TARGET/hypr"
    if [[ -L "$hypr_link" ]]; then
        log "Hyprland → N4P1x symlink already exists."
    else
        warn "Hyprland configs should be symlinked to N4P1x."
        log "Configs are currently standalone, which is fine for static setups."
    fi

    # Ensure matugen templates are accessible
    if [[ -d "$CONFIG_TARGET/matugen/templates" ]]; then
        log "matugen templates found (${#templates[@]} templates)."
    fi

    # Set up wallpaper directory
    local wall_dir="$HOME/Pictures/Wallpapers"
    if [[ ! -d "$wall_dir" || -z "$(ls -A "$wall_dir" 2>/dev/null)" ]]; then
        warn "No wallpapers found in $wall_dir"
        log "Copying sample wallpapers from repo..."
        if [[ -d "$CONFIG_TARGET/N4P1x/wallpapers" ]]; then
            cmd cp -r "$CONFIG_TARGET/N4P1x/wallpapers"/* "$wall_dir"/ 2>/dev/null || true
        fi
    fi

    # Run initial theme sync
    local sync_script="$CONFIG_TARGET/hypr/scripts/theme/sync-all"
    if [[ -f "$sync_script" ]]; then
        log "Running initial theme sync..."
        if confirm "Run theme sync now?" true; then
            cmd bash "$sync_script" || warn "Theme sync encountered issues (may need a running compositor)."
        fi
    fi

    log "Theme engine setup complete."
}

# ──────────────────────────────────────────────────────────────────────────────
# POST-INSTALL
# ──────────────────────────────────────────────────────────────────────────────

post_install() {
    head "Post-Installation"

    # Ensure fish is default shell
    if [[ "$SHELL" != *"/fish" ]]; then
        if confirm "Set Fish as your default shell?" true; then
            cmd chsh -s "$(command -v fish)" "$USER" || warn "Could not set Fish shell. Try: chsh -s $(command -v fish)"
        fi
    fi

    # Enable essential user services
    if $HAS_SYSTEMD; then
        log "Enabling user services..."
        cmd systemctl --user enable --now pipewire wireplumber 2>/dev/null || true
        cmd systemctl --user enable --now mpd 2>/dev/null || true
    fi

    # Docker rootless setup
    if command -v docker &>/dev/null; then
        if confirm "Set up rootless Docker?" true; then
            log "See: https://docs.docker.com/engine/security/rootless/"
            log "Run: dockerd-rootless-setuptool.sh install"
        fi
    fi

    # Font cache
    if command -v fc-cache &>/dev/null; then
        log "Rebuilding font cache..."
        cmd fc-cache -fv 2>/dev/null | tail -3
    fi

    log "Post-installation complete."
}

# ──────────────────────────────────────────────────────────────────────────────
# SUMMARY
# ──────────────────────────────────────────────────────────────────────────────

show_summary() {
    head "Installation Summary"

    echo -e "  ${G}Compositor:${N}     $COMPOSITOR"
    echo -e "  ${G}Terminal:${N}       $TERMINAL"
    echo -e "  ${G}Groups:${N}         ${INSTALL_GROUPS[*]}"
    echo -e "  ${G}Official pkgs:${N}  ${#OFFICIAL_PKGS[@]}"
    echo -e "  ${G}AUR pkgs:${N}       ${#AUR_PKGS[@]}"
    echo -e "  ${G}GPU:${N}            ${GPU_VENDOR^}"
    echo -e "  ${G}Log:${N}            $LOG_FILE"
    echo ""

    echo -e "  ${Y}After reboot:${N}"
    echo -e "    1. Select your compositor in SDDM or TTY:"
    echo -e "       - Hyprland:  ${C}Hyprland${N}"
    echo -e "       - Sway:      ${C}sway${N}"
    echo -e "       - Niri:      ${C}niri${N}"
    echo -e "    2. First-run setup will apply the wallpaper and theme."
    echo -e "    3. Press ${W}Super+/${N} to view all keybindings."
    echo ""

    if $HAS_SYSTEMD; then
        echo -e "  ${Y}Running services:${N}"
        echo -e "    systemctl --user list-units --type=service | grep active"
    fi

    echo ""
    if confirm "Reboot now?" false; then
        cmd systemctl reboot
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────────────────────────────────────

main() {
    detect_tui
    show_banner
    detect_system
    menu_main

    select_compositor
    select_terminal
    select_components

    resolve_packages

    # Show install plan
    head "Installation Plan"
    echo -e "  ${W}Compositor:${N}  $COMPOSITOR"
    echo -e "  ${W}Terminal:${N}    $TERMINAL"
    echo -e "  ${W}Groups:${N}      ${INSTALL_GROUPS[*]}"
    echo -e "  ${W}Packages:${N}    $((${#OFFICIAL_PKGS[@]} + ${#AUR_PKGS[@]})) total (${#OFFICIAL_PKGS[@]} official, ${#AUR_PKGS[@]} AUR)"
    confirm "Proceed with installation?" true || exit 0

    # Run phases
    install_packages
    deploy_configs
    setup_compositor
    setup_theme_engine
    post_install

    # Done
    show_summary
}

# Run with usage check
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "mini-ter v$VERSION — Arch Linux Rice Installer"
    echo ""
    echo "Usage: ./install.sh [options]"
    echo ""
    echo "Options:"
    echo "  --help, -h    Show this help message"
    echo "  --dry-run     Show what would be installed without installing"
    echo ""
    echo "Environment:"
    echo "  Install log is written to $LOG_FILE"
    exit 0
fi

if [[ "${1:-}" == "--dry-run" ]]; then
    detect_tui
    show_banner
    detect_system
    select_compositor
    select_terminal
    select_components
    resolve_packages
    head "DRY RUN — Would install:"
    echo -e "  Compositor:  $COMPOSITOR"
    echo -e "  Terminal:    $TERMINAL"
    echo -e "  Groups:      ${INSTALL_GROUPS[*]}"
    echo ""
    echo -e "  ${C}Official packages:${N}"
    printf "    %s\n" "${OFFICIAL_PKGS[@]}"
    echo ""
    echo -e "  ${Y}AUR packages:${N}"
    printf "    %s\n" "${AUR_PKGS[@]}"
    exit 0
fi

main "$@"
