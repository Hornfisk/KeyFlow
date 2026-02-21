#!/usr/bin/env bash
set -e

echo "--- KeyFlow Installer ---"

# Check dependencies
for cmd in keyfinder-cli zenity python3 notify-send; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

# Get Paths
SRC=$(zenity --file-selection --directory --title="Select Source Music Folder")
DST=$(zenity --file-selection --directory --title="Select Destination (Organized) Folder")

mkdir -p "$DST" ~/.local/bin ~/.local/share/applications

# Copy and update scripts
cp scripts/* ~/.local/bin/
chmod +x ~/.local/bin/*.py ~/.local/bin/*.sh

# Update paths in scripts
sed -i "s|SRC = .*|SRC = Path('$SRC')|" ~/.local/bin/process_keys.py
sed -i "s|DST = .*|DST = Path('$DST')|" ~/.local/bin/process_keys.py
sed -i "s|root = .*|root = Path('$DST')|" ~/.local/bin/convert_to_camelot.py

# Create Desktop Entry for Thunar
cat > ~/.local/share/applications/keyflow.desktop <<EOF
[Desktop Entry]
Name=KeyFlow (Process Keys)
Exec=/home/$USER/.local/bin/process_keys_thunar.sh %F
Icon=audio-x-generic
Type=Application
Terminal=false
EOF

echo "Installation complete! Restart Thunar to see the right-click action."
