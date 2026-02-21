#!/usr/bin/env bash
# process_keys_rofi.sh - rofi launcher for KeyFlow / Key processing
set -euo pipefail

HOME_DIR="$HOME"
BASE="${HOME_DIR}/Music/DJ_Tunes"
WRAPPER="${HOME_DIR}/.local/bin/process_keys_thunar.sh"

# Ensure wrapper exists
if [ ! -x "$WRAPPER" ]; then
  echo "Error: wrapper not found or not executable: $WRAPPER" >&2
  exit 1
fi

# Build list of candidate folders (show relative to $HOME for brevity)
if [ -d "$BASE" ]; then
  mapfile -t choices < <(find "$BASE" -mindepth 1 -maxdepth 4 -type d -print | sed "s|^${HOME_DIR}/||" | sort)
else
  choices=()
fi

# Add a manual-picker option at the end
choices+=("Pick a folder with file dialog...")

# Ask user via rofi
selection="$(printf '%s\n' "${choices[@]}" | rofi -dmenu -i -p "Select folder to process:")"
[ -z "$selection" ] && exit 0

if [ "$selection" = "Pick a folder with file dialog..." ]; then
  # fallback gui picker
  if command -v zenity >/dev/null 2>&1; then
    DIR="$(zenity --file-selection --directory --title="Select Music Folder to Process")" || exit 0
  else
    DIR="$(rofi -dmenu -p "Enter full path:")"
    [ -z "$DIR" ] && exit 0
  fi
else
  # selection is relative to $HOME
  DIR="${HOME_DIR}/${selection}"
fi

# Final existence check
if [ ! -d "$DIR" ]; then
  notify-send "KeyFlow" "Selected path not found: $DIR"
  exit 1
fi

# Call the wrapper which runs analysis + Camelot conversion
"$WRAPPER" "$DIR"

notify-send "KeyFlow" "Processing complete" "Processed: $DIR"
exit 0
