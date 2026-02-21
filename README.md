# KeyFlow 🎧

KeyFlow is a lightweight automation tool for DJs on Linux (Arch/Hyprland/Thunar). It analyzes musical keys, strips annoying track numbers, and organizes your library into a clean Camelot-tagged structure.

## Features
- **Key Detection:** Uses `keyfinder-cli` for high accuracy.
- **Auto-Cleaning:** Removes leading numbers (e.g., `01 - `) and old key tags.
- **Camelot Conversion:** Automatically converts traditional keys (Am) to Camelot (8A).
- **Integration:** Works via Rofi/App Launcher or Thunar Right-Click.

## Dependencies
Before running the installer, ensure you have the following installed:
- `python3`
- `keyfinder-cli` (Available in AUR for Arch users)
- `zenity` (For folder selection dialogs)
- `rofi` (For the app launcher integration)
- `libnotify` (For desktop notifications)

You can install these on Arch Linux with:
```bash
sudo pacman -S python keyfinder-cli zenity rofi libnotify

Installation
Clone this repository and run the installer script:

git clone https://github.com/Hornfisk/KeyFlow.git
cd KeyFlow
chmod +x install.sh
./install.sh
The installer will prompt you to select your source music folder (e.g., ~/Music/DJ_Tunes) and your destination folder (e.g., ~/Music/Organized). It will then set up all scripts and desktop integrations.

Usage
Thunar (Right-Click)
Navigate to any music folder or select specific files.
Right-click and select "KeyFlow (Process Keys)".
The processed copies will appear in your destination folder with Camelot keys prepended.
Rofi (App Launcher)
Open your app launcher or Rofi.
Search for "KeyFlow (Process Folder)".
Select the folder you want to process.
Wait for the notification confirming completion.
File Transformation Logic
Input: ~/Music/DJ_Tunes/Techno/015 - Sergie Rezza - Monte.mp3
Step 1 (Analysis): Detects key (e.g., Em), strips 015 - .
Step 2 (Copy): ~/Music/Organized/Techno/[Em] Sergie Rezza - Monte.mp3
Step 3 (Convert): ~/Music/Organized/Techno/[9A] Sergie Rezza - Monte.mp3
Troubleshooting & Maintenance
Logs: Run ~/.local/bin/process_keys.py /path/to/music in a terminal to see real-time output.
Cleanup: macOS metadata files (._*) and .DS_Store are ignored automatically.
Duplicates: If a file already exists in the destination, a numeric suffix is appended to avoid overwriting.
Restart Thunar: After installation, restart Thunar (thunar -q && thunar &) to activate the right-click action.
License
This project is licensed under the MIT License. See the LICENSE file for details.
