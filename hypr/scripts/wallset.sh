#!/usr/bin/env bash

set -euo pipefail

LOCKDIR="${XDG_RUNTIME_DIR:-/tmp}/N4P1x-wallpaper.lock"
if ! mkdir "$LOCKDIR" 2>/dev/null; then
    exit 0
fi

COOLDOWN_MS=900
STAMP_FILE="${XDG_RUNTIME_DIR:-/tmp}/N4P1x-wallpaper.last"
update_stamp() { date +%s%3N 2>/dev/null > "$STAMP_FILE" || echo "$(( $(date +%s) * 1000 ))" > "$STAMP_FILE"; }
trap 'update_stamp; rmdir "$LOCKDIR" 2>/dev/null || true' EXIT
now_ms="$(date +%s%3N 2>/dev/null || echo "$(( $(date +%s) * 1000 ))")"
last_ms="$(cat "$STAMP_FILE" 2>/dev/null || echo 0)"
if [[ "$last_ms" =~ ^[0-9]+$ ]] && (( now_ms - last_ms < COOLDOWN_MS )); then
    exit 0
fi
echo "$now_ms" > "$STAMP_FILE"

DIR="${HOME}/Pictures/Wallpapers"
[[ -d "$HOME/Wallpapers" ]] && DIR="$HOME/Wallpapers"
MATUGEN_CONFIG="$HOME/.config/matugen/config.toml"

if [[ ! -d "$DIR" ]]; then
    notify-send "No backgrounds" "Wallpapers folder not found" >/dev/null 2>&1 || true
    exit 1
fi

mapfile -t IMAGES < <(find "$DIR" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.gif" -o \
    -iname "*.webp" \
\))

if (( ${#IMAGES[@]} == 0 )); then
    notify-send "No wallpapers" "No images in $DIR" >/dev/null 2>&1 || true
    exit 1
fi

RANDOM_PIC="${IMAGES[RANDOM % ${#IMAGES[@]}]}"

if command -v swww >/dev/null 2>&1; then
    swww img "$RANDOM_PIC" --transition-type grow --transition-pos top-right --transition-fps 60 --transition-duration 0.45 >/dev/null 2>&1 &
elif command -v awww >/dev/null 2>&1; then
    pgrep -x "awww-daemon" >/dev/null 2>&1 || awww-daemon >/dev/null 2>&1 &
    awww img "$RANDOM_PIC" >/dev/null 2>&1 &
fi

cp -f "$RANDOM_PIC" "$HOME/.config/N4P1x/current/wallpaper" 2>/dev/null || true

notify-send -i "$RANDOM_PIC" "Wallpaper" "$(basename "$RANDOM_PIC")" >/dev/null 2>&1 &

(
    MATUGEN_LOCK="${XDG_RUNTIME_DIR:-/tmp}/N4P1x-matugen.lock"
    if command -v matugen >/dev/null 2>&1 && mkdir "$MATUGEN_LOCK" 2>/dev/null; then
        trap "rmdir '$MATUGEN_LOCK' 2>/dev/null || true" EXIT
        matugen image "$RANDOM_PIC" -c "$MATUGEN_CONFIG" --quiet --prefer saturation
    fi
    N4P1X_SKIP_WALLPAPER=1 N4P1X_FAST_SYNC=1 "$HOME/.config/hypr/scripts/theme/sync-all"
) &>/dev/null &
