# ii on Niri

A Quickshell shell for Niri. Fork of end-4's illogical-impulse, butchered to work on a different compositor.

| Overview | Sidebars |
|:---|:---|
| ![Overview](https://github.com/user-attachments/assets/9faaad0e-a665-4747-9428-ea94756e1f0f) | ![Sidebars](https://github.com/user-attachments/assets/21e43f3e-d6d9-4625-8210-642f9c05509b) |

| Settings | Overlay |
|:---|:---|
| ![Settings](https://github.com/user-attachments/assets/25700a1c-70e6-4456-b053-35cf83fcac7a) | ![Overlay](https://github.com/user-attachments/assets/1d5ca0f0-6ffb-46da-be1a-2d5e494089e7) |

---

## What is this

A shell. Bar at the top, sidebars on the sides, overlays that pop up when you press keys. The usual.

- **Bar** - clock, workspaces, tray, the stuff you expect
- **Sidebars** - left one has AI chat and apps, right one has toggles and a notepad
- **Overview** - workspace grid, adapted for Niri's scrolling model
- **Alt+Tab** - window switcher that actually works across workspaces
- **Clipboard** - history panel with search (needs cliphist)
- **Region tools** - screenshots, screen recording, OCR, reverse image search
- **Wallpaper stuff** - picker, matugen colors, video wallpaper support
- **Settings** - GUI config with search, so you don't have to edit JSON like a caveman

---

## Documentation

Read these or suffer.

| Doc | What's in it |
|-----|--------------|
| [docs/INSTALL.md](docs/INSTALL.md) | How to install this thing |
| [docs/PACKAGES.md](docs/PACKAGES.md) | Every package the installer uses, by category |
| [docs/KEYBINDS.md](docs/KEYBINDS.md) | Default keyboard shortcuts |
| [docs/IPC.md](docs/IPC.md) | All IPC targets for custom keybindings |
| [docs/SETUP.md](docs/SETUP.md) | How the setup script works, updates, uninstall |

---

## Quick Install

Arch-based? Run this:

```bash
git clone https://github.com/snowarch/quickshell-ii-niri.git
cd quickshell-ii-niri
./setup install -y
```

Not on Arch? Check [docs/INSTALL.md](docs/INSTALL.md) for manual steps.

---

## Keybinds (the important ones)

These come configured by default:

| Key | What it does |
|-----|--------------|
| `Alt+Tab` | Window switcher |
| `Super+V` | Clipboard history |
| `Super+G` | Overlay (search, widgets) |
| `Super+Shift+S` | Region screenshot |
| `Super+Shift+X` | Region OCR |
| `Ctrl+Alt+T` | Wallpaper picker |
| `Super+/` | Keyboard shortcuts cheatsheet |

Full list in [docs/KEYBINDS.md](docs/KEYBINDS.md).

---

## IPC (for custom bindings)

ii exposes IPC targets you can bind to keys. The syntax:

```kdl
bind "Key" { spawn "qs" "-c" "ii" "ipc" "call" "<target>" "<function>"; }
```

Main targets:

| Target | Functions |
|--------|-----------|
| `overview` | `toggle` |
| `overlay` | `toggle` |
| `clipboard` | `toggle`, `open`, `close` |
| `altSwitcher` | `next`, `previous`, `toggle` |
| `region` | `screenshot`, `ocr`, `search`, `record` |
| `session` | `toggle` |
| `lock` | `activate` |
| `cheatsheet` | `toggle` |
| `sidebarLeft` | `toggle` |
| `sidebarRight` | `toggle` |
| `wallpaperSelector` | `toggle` |
| `mpris` | `playPause`, `next`, `previous` |
| `brightness` | `increment`, `decrement` |

Full reference with examples: [docs/IPC.md](docs/IPC.md)

---

## Fair warning

This is my daily driver. It works. Most of the time. I break things when I'm bored.

If something explodes, check the logs:

```bash
qs log -c ii
```

If you want something stable and polished, check out end-4's original ii for Hyprland instead.

---

## Credits

- [**end-4 – illogical-impulse for Hyprland**](https://github.com/end-4/dots-hyprland)
- [**Quickshell**](https://quickshell.outfoxxed.me/) – the framework that makes this possible
- [**Niri**](https://github.com/YaLTeR/niri) – the compositor that doesn't crash
