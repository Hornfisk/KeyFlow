# KeyFlow 🎧

KeyFlow is a lightweight automation tool for DJs on Linux (Arch/Hyprland/Thunar). It analyzes musical keys, strips annoying track numbers, and organizes your library into a clean Camelot-tagged structure.

### Features
- **Key Detection:** Uses `keyfinder-cli` for high accuracy.
- **Auto-Cleaning:** Removes leading numbers (e.g., `01 - `) and old key tags.
- **Camelot Conversion:** Automatically converts traditional keys (Am) to Camelot (8A).
- **Integration:** Works via Rofi/App Launcher or Thunar Right-Click.

### Installation
1. Install dependencies: `sudo pacman -S keyfinder-cli zenity libnotify`
2. Clone this repo.
3. Run `./install.sh` and follow the GUI prompts.

### Usage
- **Thunar:** Right-click any folder or file -> `KeyFlow (Process Keys)`.
- **Rofi:** Search for `KeyFlow` and select a folder to process.
