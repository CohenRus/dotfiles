#!/usr/bin/env bash
# Waybar media module — title of whatever audio is playing (any MPRIS player).
# Shows the first MAX_LEN characters, truncated (no scrolling).
# Emits one line per update; waybar re-renders on each line.
set -u

MAX_LEN=25
IDLE_SEC=0.75     # poll interval when nothing playing

command -v playerctl >/dev/null 2>&1 || { echo "playerctl not found" >&2; exit 1; }

emit() { printf '%s\n' "$1"; }

# First player currently Playing, else nothing.
playing_player() {
  local p
  for p in $(playerctl --list-all 2>/dev/null); do
    [ "$(playerctl --player "$p" status 2>/dev/null)" = "Playing" ] && { printf '%s\n' "$p"; return 0; }
  done
  return 1
}

while :; do
  player="$(playing_player)" || { emit ""; sleep "$IDLE_SEC"; continue; }

  title="$(playerctl --player "$player" metadata title 2>/dev/null)"
  [ -z "$title" ] && { emit ""; sleep "$IDLE_SEC"; continue; }

  emit "${title:0:MAX_LEN}"
  sleep "$IDLE_SEC"
done
