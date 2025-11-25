# ii on Niri

A Quickshell configuration for Niri, forked from end-4's illogical-impulse.

---

## Screenshots

| Overview | Sidebars |
|:---|:---|
| ![Overview](https://github.com/user-attachments/assets/9faaad0e-a665-4747-9428-ea94756e1f0f) | ![Sidebars](https://github.com/user-attachments/assets/21e43f3e-d6d9-4625-8210-642f9c05509b) |

| Settings | Overlay |
|:---|:---|
| ![Settings](https://github.com/user-attachments/assets/25700a1c-70e6-4456-b053-35cf83fcac7a) | ![Overlay](https://github.com/user-attachments/assets/1d5ca0f0-6ffb-46da-be1a-2d5e494089e7) |

---

## What's Here

- **Bar, sidebars, overview** - the usual shell stuff, adapted for Niri
- **Alt+Tab switcher** - cycles windows across all workspaces with MRU order
- **Clipboard panel** - cliphist-based, with search and previews
- **Region tools** - screenshots, recording, OCR, image search
- **Wallpaper pipeline** - matugen colors, video wallpapers, backdrop blur
- **Settings UI** - searchable config with live preview

The compositor layer (`NiriService`) talks to Niri via socket for workspace/window tracking, keyboard layout switching, and output management.

---

## Requirements

- **Niri** 25.08+
- **Quickshell** 0.2.0+ (AUR: `quickshell-git`)
- **matugen** for theming
- **cliphist** + **wl-clipboard** for clipboard
- Optional: DMS if you want both shells running

See [docs/INSTALL.md](docs/INSTALL.md) for the full dependency list.

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
