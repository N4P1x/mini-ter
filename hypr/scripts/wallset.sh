#!/usr/bin/env bash

set -euo pipefail

LOCKDIR="${XDG_RUNTIME_DIR:-/tmp}/catbug0x1-wallpaper.lock"
if ! mkdir "$LOCKDIR" 2>/dev/null; then
    exit 0
fi

COOLDOWN_MS=900
STAMP_FILE="${XDG_RUNTIME_DIR:-/tmp}/catbug0x1-wallpaper.last"
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

cp -f "$RANDOM_PIC" "$HOME/.config/catbug0x1/current/wallpaper" 2>/dev/null || true

notify-send -i "$RANDOM_PIC" "Wallpaper" "$(basename "$RANDOM_PIC")" >/dev/null 2>&1 &

if command -v matugen >/dev/null 2>&1; then
    WALL="$RANDOM_PIC" MATUGEN_CONFIG="$MATUGEN_CONFIG" HOME="$HOME" \
        nohup bash -lc 'matugen image "$WALL" -c "$MATUGEN_CONFIG" --quiet --prefer saturation >/dev/null 2>&1 || true; CATBUG0X1_SKIP_WALLPAPER=1 CATBUG0X1_FAST_SYNC=1 "$HOME/.config/hypr/scripts/theme/sync-all" >/dev/null 2>&1 || true' \
        >/dev/null 2>&1 &
else
    HOME="$HOME" nohup bash -lc 'CATBUG0X1_SKIP_WALLPAPER=1 CATBUG0X1_FAST_SYNC=1 "$HOME/.config/hypr/scripts/theme/sync-all" >/dev/null 2>&1 || true' >/dev/null 2>&1 &
fi
