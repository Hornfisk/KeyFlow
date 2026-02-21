#!/usr/bin/env bash
set -euo pipefail

# KeyFlow installer
# Usage: ./install.sh
#
# - Prompts for source and destination folders (via zenity)
# - Copies scripts to ~/.local/bin
# - Installs .desktop files to ~/.local/share/applications
# - Rewrites SRC/DST placeholders in process_keys.py and convert_to_camelot.py
# - Makes installed scripts executable

# -------- helpers --------
err() { printf '%s\n' "ERROR: $*" >&2; }
info() { printf '%s\n' "INFO: $*"; }

check_cmd() {
  command -v "$1" >/dev/null 2>&1 || return 1
}

# -------- deps --------
REQ_CMDS=(keyfinder-cli zenity python3 notify-send)
MISSING=()
for c in "${REQ_CMDS[@]}"; do
  if ! check_cmd "$c"; then
    MISSING+=("$c")
  fi
done
if [ "${#MISSING[@]}" -gt 0 ]; then
  err "Missing dependencies: ${MISSING[*]}"
  err "Install them before continuing (e.g. on Arch: sudo pacman -S keyfinder-cli zenity libnotify)."
  exit 1
fi

# -------- choose folders --------
SRC=$(zenity --file-selection --directory --title="Select Source Music Folder (DJ_Tunes)" 2>/dev/null || true)
if [ -z "${SRC:-}" ]; then
  err "No source folder selected. Aborting."
  exit 1
fi
DST=$(zenity --file-selection --directory --title="Select Destination (Organized) Folder" 2>/dev/null || true)
if [ -z "${DST:-}" ]; then
  err "No destination folder selected. Aborting."
  exit 1
fi

# normalize to absolute paths
SRC=$(readlink -f "$SRC")
DST=$(readlink -f "$DST")

info "Source: $SRC"
info "Destination: $DST"

# -------- install locations --------
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
mkdir -p "$BIN_DIR" "$APP_DIR" "$DST"

# -------- copy scripts --------
if [ ! -d "scripts" ]; then
  err "Required 'scripts' directory not found in current folder. Run this installer from the repo root."
  exit 1
fi

info "Copying scripts to $BIN_DIR"
cp -a scripts/* "$BIN_DIR"/

info "Setting executable permissions"
chmod +x "$BIN_DIR"/*.py "$BIN_DIR"/*.sh || true

# -------- patch scripts with chosen paths --------
# Replace lines that define SRC / DST / root. If original uses different form, sed will still attempt replacements.
if grep -qE '^SRC\s*=' "$BIN_DIR/process_keys.py" 2>/dev/null; then
  sed -i "s|^SRC\s*=.*$|SRC = Path(\"$SRC\")|" "$BIN_DIR/process_keys.py"
else
  # attempt to insert if not present
  sed -i "1s|^|from pathlib import Path\nSRC = Path(\"$SRC\")\n|" "$BIN_DIR/process_keys.py"
fi

if grep -qE '^DST\s*=' "$BIN_DIR/process_keys.py" 2>/dev/null; then
  sed -i "s|^DST\s*=.*$|DST = Path(\"$DST\")|" "$BIN_DIR/process_keys.py"
else
  sed -i "1s|^|DST = Path(\"$DST\")\n|" "$BIN_DIR/process_keys.py"
fi

# convert_to_camelot.py: set default root to DST if a default exists
if grep -qE '^root\s*=' "$BIN_DIR/convert_to_camelot.py" 2>/dev/null; then
  sed -i "s|^root\s*=.*$|root = Path(\"$DST\")|" "$BIN_DIR/convert_to_camelot.py"
else
  sed -i "1s|^|from pathlib import Path\nroot = Path(\"$DST\")\n|" "$BIN_DIR/convert_to_camelot.py"
fi

# -------- .desktop files --------
# If repo has a desktop/ folder, copy those first, else create sane defaults
if [ -d "desktop" ]; then
  info "Installing .desktop files from repo/desktop"
  cp -a desktop/*.desktop "$APP_DIR/" 2>/dev/null || true
else
  info "Creating default .desktop entries"
  cat > "$APP_DIR/keyflow-rofi.desktop" <<EOF
[Desktop Entry]
Name=KeyFlow (Process Folder)
Comment=Select a folder to analyze and organize keys
Exec=$BIN_DIR/process_keys_rofi.sh
Icon=audio-x-generic
Terminal=false
Type=Application
Categories=AudioVideo;Audio;
EOF

  cat > "$APP_DIR/keyflow-thunar.desktop" <<EOF
[Desktop Entry]
Name=KeyFlow (Right-Click)
Comment=Process selected files or folders with KeyFlow
Exec=$BIN_DIR/process_keys_thunar.sh %F
Icon=audio-x-generic
Terminal=false
Type=Application
Categories=AudioVideo;Audio;
EOF
fi

# ensure wrapper script exists; create a safe wrapper if missing
if [ ! -x "$BIN_DIR/process_keys_thunar.sh" ]; then
  info "Creating fallback wrapper process_keys_thunar.sh"
  cat > "$BIN_DIR/process_keys_thunar.sh" <<'EOF'
#!/usr/bin/env bash
# wrapper: run analysis (+ camelot conversion) for given paths
set -euo pipefail
BIN_DIR="$HOME/.local/bin"
if [ "$#" -eq 0 ]; then
  echo "Usage: process_keys_thunar.sh <file-or-dir> [...]" >&2
  exit 1
fi
for p in "$@"; do
  "$BIN_DIR/process_keys.py" "$p"
done
"$BIN_DIR/convert_to_camelot.py" "$HOME/Music/Organized" || true
notify-send "KeyFlow" "Processing finished"
EOF
  chmod +x "$BIN_DIR/process_keys_thunar.sh"
fi

# ensure rofi launcher exists; create fallback if missing
if [ ! -x "$BIN_DIR/process_keys_rofi.sh" ]; then
  info "Creating fallback rofi launcher process_keys_rofi.sh"
  cat > "$BIN_DIR/process_keys_rofi.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
HOME_DIR="$HOME"
BASE="${HOME_DIR}/Music/DJ_Tunes"
WRAPPER="${HOME_DIR}/.local/bin/process_keys_thunar.sh"
if [ ! -x "$WRAPPER" ]; then
  echo "Wrapper not found: $WRAPPER" >&2
  exit 1
fi
if [ -d "$BASE" ]; then
  mapfile -t choices < <(find "$BASE" -mindepth 1 -maxdepth 4 -type d -print | sed "s|^${HOME_DIR}/||" | sort)
else
  choices=()
fi
choices+=("Pick a folder with file dialog...")
selection="$(printf '%s\n' "${choices[@]}" | rofi -dmenu -i -p "Select folder to process:")"
[ -z "$selection" ] && exit 0
if [ "$selection" = "Pick a folder with file dialog..." ]; then
  DIR="$(zenity --file-selection --directory --title="Select Music Folder to Process")" || exit 0
else
  DIR="${HOME}/${selection}"
fi
[ -d "$DIR" ] || { notify-send "KeyFlow" "Selected path not found: $DIR"; exit 1; }
"$WRAPPER" "$DIR"
notify-send "KeyFlow" "Processing complete" "Processed: $DIR"
EOF
  chmod +x "$BIN_DIR/process_keys_rofi.sh"
fi

# -------- update desktop database (if available) --------
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

info "Installation complete."
info "Next steps:"
info " - Restart Thunar for the right-click action: thunar -q && thunar &"
info " - Rofi/App launcher: look for 'KeyFlow (Process Folder)' or run $BIN_DIR/process_keys_rofi.sh"
info " - Test one folder: $BIN_DIR/process_keys_thunar.sh \"$SRC\""

exit 0
