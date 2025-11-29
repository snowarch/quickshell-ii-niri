# Default Keybinds

These are the default keybinds shipped in `dots/.config/niri/config.kdl`. Customize them to your liking.

---

## ii Controls

| Key | Action |
|-----|--------|
| `Super+Tab` | Niri overview (native compositor) |
| `Mod+Space` (`Super+Space`) | ii overview (daemon) |
| `Super+G` | ii overlay (search, widgets) |
| `Alt+Tab` | ii window switcher (next) |
| `Alt+Shift+Tab` | ii window switcher (previous) |
| `Super+V` | Clipboard history |
| `Super+/` | Cheatsheet |
| `Super+,` | Settings |
| `Super+Alt+L` | Lock screen |
| `Ctrl+Alt+T` | Wallpaper selector |

---

## Region Tools

| Key | Action |
|-----|--------|
| `Super+Shift+S` | Region screenshot |
| `Super+Shift+X` | Region OCR |
| `Super+Shift+A` | Region image search |
| `Print` | Full screenshot (native) |
| `Ctrl+Print` | Screenshot current screen |
| `Alt+Print` | Screenshot current window |

---

## Window Management

| Key | Action |
|-----|--------|
| `Super+Q` | Close window |
| `Super+D` | Maximize column |
| `Super+F` | Toggle fullscreen |
| `Super+A` | Toggle floating |

### Focus

| Key | Action |
|-----|--------|
| `Super+Left/H` | Focus left |
| `Super+Right/L` | Focus right |
| `Super+Up/K` | Focus up |
| `Super+Down/J` | Focus down |

### Move

| Key | Action |
|-----|--------|
| `Super+Shift+Left/H` | Move left |
| `Super+Shift+Right/L` | Move right |
| `Super+Shift+Up/K` | Move up |
| `Super+Shift+Down/J` | Move down |

---

## Workspaces

| Key | Action |
|-----|--------|
| `Super+1-9` | Focus workspace 1-9 |
| `Super+Shift+1-5` | Move window to workspace 1-5 |

---

## Applications

| Key | Action |
|-----|--------|
| `Super+T` / `Super+Return` | Terminal (foot) |
| `Super+E` | File manager (dolphin) |

---

## System

| Key | Action |
|-----|--------|
| `Super+Shift+E` | Quit Niri |
| `Super+Shift+O` | Power off monitors |
| `Super+Escape` | Toggle keyboard shortcuts inhibit |

---

## Media Keys

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |

---

## Customizing

Edit `~/.config/niri/config.kdl` to change keybinds. See [IPC.md](IPC.md) for all available ii targets you can bind.

Example:

```kdl
binds {
    // Your custom binds
    Super+P { spawn "qs" "-c" "ii" "ipc" "call" "session" "toggle"; }
}
```

Reload Niri config after changes:

```bash
niri msg action reload-config
```
