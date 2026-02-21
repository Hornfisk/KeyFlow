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
