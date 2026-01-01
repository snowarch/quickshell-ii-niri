# ii on Niri

A Quickshell shell for Niri. Fork of end-4's illogical-impulse, butchered to work on a different compositor.

> [!CAUTION]
> **Hey.** This is my personal rice. I put effort into it, but it's not a product - don't expect hand-holding or stability guarantees. If you're just here because "it looks cool" and have no clue what Niri even is, maybe check out something more beginner-friendly first. Your system, your responsibility.
>
> **Heads up:** almost everything here is configurable. Modules, colors, fonts, animations - if something bugs you, there's probably a toggle for it. Hit `Super+,` for settings before you rage-quit.

suggest, ask or wherever: [Discord](https://discord.gg/pAPTfAhZUJ)

### Material ii

| Overview | Sidebars |
|:---|:---|
| ![Overview](https://github.com/user-attachments/assets/9faaad0e-a665-4747-9428-ea94756e1f0f) | ![Sidebars](https://github.com/user-attachments/assets/21e43f3e-d6d9-4625-8210-642f9c05509b) |

| Overlay/Search | Settings |
|:---|:---|
| ![Settings](https://github.com/user-attachments/assets/25700a1c-70e6-4456-b053-35cf83fcac7a) | ![Overlay](https://github.com/user-attachments/assets/1d5ca0f0-6ffb-46da-be1a-2d5e494089e7) |

### Waffle (Windows 11 style)

| Quick Settings | Start Menu + Widgets |
|:---|:---|
| ![Waffle Start](https://github.com/user-attachments/assets/5c5996e7-90eb-4789-9921-0d5fe5283fa3) | ![Waffle Settings](https://github.com/user-attachments/assets/fadf9562-751e-4138-a3a1-b87b31114d44) |

---

## What is this

A shell. Bar at the top, sidebars on the sides, overlays that pop up when you press keys. The usual.

- **Bar** - clock, workspaces, tray, the stuff you expect
- **Sidebars** - left one has AI chat and wallpaper browser, right one has quick toggles and a notepad
- **Overview** - workspace grid, adapted for Niri's scrolling model
- **Alt+Tab** - window switcher that actually works across workspaces
- **Clipboard** - history panel with search (needs cliphist)
- **Region tools** - screenshots, screen recording, OCR, reverse image search
- **Wallpaper** - picker, video support, and matugen pulls colors from whatever you set
- **Theming** - presets like Gruvbox and Catppuccin, or build your own with the custom theme editor. Fonts are customizable too
- **Settings** - GUI config with search, so you don't have to edit JSON like a caveman
- **GameMode** - fullscreen app? Effects go bye-bye. Your games won't stutter
- **Idle** - screen off, lock, suspend timeouts. swayidle handles it, you configure it

### Panel families

Can't decide on a look? Good news, you don't have to.

- **Material ii** - The OG. Floating bar, sidebars, that Material Design aesthetic.
- **Waffle** - Taskbar at the bottom, action center, tray overflow. For the "I kinda miss Windows" crowd.

Press `Mod+Shift+W` to cycle between families, or go to Settings → Modules to mix and match.

### Global styles

Not enough customization? Slap a visual style on top:

- **Material** - The default. Solid backgrounds, clean lines.
- **Aurora** - Glass effect. Your wallpaper bleeds through panels. Fancy.
- **Inir** - TUI vibes. Accent borders, darker everything. For terminal addicts.

Settings → Themes → Global Style. Go wild.

---

## Documentation

Read these or suffer.

| Doc | What's in it |
|-----|--------------|
| [docs/INSTALL.md](docs/INSTALL.md) | Installation guide |
| [docs/SETUP.md](docs/SETUP.md) | Setup script, updates, migrations, rollback |
| [docs/KEYBINDS.md](docs/KEYBINDS.md) | Default keyboard shortcuts |
| [docs/IPC.md](docs/IPC.md) | IPC targets for custom keybindings |
| [docs/PACKAGES.md](docs/PACKAGES.md) | Package list by category |
| [docs/LIMITATIONS.md](docs/LIMITATIONS.md) | Known limitations (read before complaining) |

---

## Quick Install

Arch-based? Run this:

```bash
git clone https://github.com/snowarch/quickshell-ii-niri.git
cd quickshell-ii-niri
./setup install
```

Not on Arch? Check [docs/INSTALL.md](docs/INSTALL.md) for manual steps. Good luck.

---

## Updating

```bash
git pull
./setup update
```

Your configs stay untouched. New features are offered as optional migrations. If something breaks, `./setup rollback` has your back.

---

## Keybinds (the important ones)

These come configured by default:

| Key | What it does |
|-----|--------------|
| `Mod+Tab` | Niri overview (native) |
| `Mod+Space` | ii overview (search/workspaces nav) |
| `Alt+Tab` | ii window switcher |
| `Super+G` | ii overlay (widgets/utils) |
| `Super+V` | Clipboard history |
| `Super+Shift+S` | Region screenshot |
| `Super+Shift+X` | Region OCR |
| `Ctrl+Alt+T` | Wallpaper picker |
| `Super+/` | Keyboard shortcuts cheatsheet |
| `Super+,` | Settings |

Full list in [docs/KEYBINDS.md](docs/KEYBINDS.md).

---

## IPC (for nerds who want custom bindings)

ii exposes IPC targets you can bind to whatever keys you want. Syntax:

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
| `settings` | `open` |
| `sidebarLeft` | `toggle` |
| `sidebarRight` | `toggle` |
| `widgetBar` | `toggle`, `open`, `close` |
| `wallpaperSelector` | `toggle` |
| `panelFamily` | `cycle`, `set` |
| `mpris` | `playPause`, `next`, `previous` |
| `brightness` | `increment`, `decrement` |
| `audio` | `volumeUp`, `volumeDown`, `mute`, `micMute` |
| `gamemode` | `toggle`, `activate`, `deactivate`, `status` |
| `notifications` | `test`, `clearAll`, `toggleSilent` |

Full reference with examples: [docs/IPC.md](docs/IPC.md)

---

## Troubleshooting

Something broke? Shocking.

```bash
# Check the logs
qs log -c ii

# Restart ii without restarting Niri
qs kill -c ii && qs -c ii

# Run diagnostics and auto-fix common issues
./setup doctor

# Undo last update if everything went sideways
./setup rollback
```

If you're still stuck, the logs usually tell you what's missing. Usually.

---

## Fair warning

This is my daily driver. It works. Most of the time. I break things when I'm bored.

This fork diverged a lot from the original - different compositor, different features, different bugs. If you want the Hyprland version, check out end-4's original.

---

## Credits

- [**end-4**](https://github.com/end-4/dots-hyprland) – illogical-impulse for Hyprland
- [**Quickshell**](https://quickshell.outfoxxed.me/) – the framework that makes this possible
- [**Niri**](https://github.com/YaLTeR/niri) – the compositor that doesn't crash

---
