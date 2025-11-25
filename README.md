# ii on Niri

A Quickshell shell for Niri, forked from end-4's illogical-impulse.

| Overview | Sidebars |
|:---|:---|
| ![Overview](https://github.com/user-attachments/assets/9faaad0e-a665-4747-9428-ea94756e1f0f) | ![Sidebars](https://github.com/user-attachments/assets/21e43f3e-d6d9-4625-8210-642f9c05509b) |

| Settings | Overlay |
|:---|:---|
| ![Settings](https://github.com/user-attachments/assets/25700a1c-70e6-4456-b053-35cf83fcac7a) | ![Overlay](https://github.com/user-attachments/assets/1d5ca0f0-6ffb-46da-be1a-2d5e494089e7) |

---

## Features

- **Bar + sidebars** with media controls, system toggles, notepad
- **Overview** adapted for Niri's scrolling workspace model
- **Alt+Tab** cycling windows across all workspaces (MRU order)
- **Clipboard panel** with search, previews, and history (cliphist)
- **Region tools** for screenshots, recording, OCR, image search
- **Wallpaper pipeline** with matugen colors and video wallpaper support
- **Settings UI** with global search and live preview

Everything talks to Niri via socket (`NiriService`) for workspace tracking, window management, and keyboard layouts.

---

## Installation

### Quick (Arch-based)

```bash
git clone https://github.com/snowarch/quickshell-ii-niri.git
cd quickshell-ii-niri
./setup install
```

### Manual

```bash
git clone https://github.com/snowarch/quickshell-ii-niri.git ~/.config/quickshell/ii
cp -r dots/.config/* ~/.config/
```

Then add to `~/.config/niri/config.kdl`:

```kdl
spawn-at-startup "qs" "-c" "ii"
```

More details in [docs/INSTALL.md](docs/INSTALL.md).

---

## IPC Targets

Bind these in your Niri config:

```kdl
// Examples
bind "Super" { spawn "qs" "ipc" "-c" "ii" "call" "overview" "toggle"; }
bind "Super+V" { spawn "qs" "ipc" "-c" "ii" "call" "clipboard" "toggle"; }
bind "Super+Shift+S" { spawn "qs" "ipc" "-c" "ii" "call" "region" "snip"; }
```

Available targets: `overview`, `clipboard`, `sidebar`, `cheatsheet`, `session`, `region`, `lock`.

---

## Notes

This is my daily driver config. It works for me but might need tweaking for your setup. I break things sometimes.

If you're looking for a stable, polished experience, check out end-4's original ii for Hyprland.

---

## Credits

- **end-4** for the original illogical-impulse
- **Quickshell** devs for the framework
