# IPC Reference

ii exposes IPC targets you can call from Niri keybinds, scripts, or your terminal when you're feeling fancy.

From terminal (for testing, or showing off):

```bash
qs -c ii ipc call <target> <function>
```

In Niri config (for actual keybinds):

```kdl
bind "Key" { spawn "qs" "-c" "ii" "ipc" "call" "<target>" "<function>"; }
```

Yes, it's verbose. No, there's no shorter way. Welcome to IPC.

---

## Available Targets

Everything ii can do, exposed for your scripting pleasure.

### overview

Toggle the workspace overview panel. The one with all your windows looking tiny and organized.

| Function | Description |
|----------|-------------|
| `toggle` | Open/close overview |

```kdl
bind "Mod+Space" { spawn "qs" "-c" "ii" "ipc" "call" "overview" "toggle"; }
```

---

### overlay

The central overlay. Search, quick actions, widgets. The thing that pops up and makes you feel productive.

| Function | Description |
|----------|-------------|
| `toggle` | Open/close overlay |

```kdl
bind "Super+G" { spawn "qs" "-c" "ii" "ipc" "call" "overlay" "toggle"; }
```

---

### clipboard

Clipboard history panel. Because Ctrl+V only remembers one thing, and that's not enough for power users.

| Function | Description |
|----------|-------------|
| `toggle` | Open/close panel |
| `open` | Open panel |
| `close` | Close panel |

```kdl
bind "Super+V" { spawn "qs" "-c" "ii" "ipc" "call" "clipboard" "toggle"; }
```

---

### altSwitcher

Alt+Tab window switcher. Works across workspaces, unlike some other implementations we won't name.

| Function | Description |
|----------|-------------|
| `toggle` | Toggle switcher |
| `open` | Open switcher |
| `close` | Close switcher |
| `next` | Focus next window |
| `previous` | Focus previous window |

```kdl
bind "Alt+Tab" { spawn "qs" "-c" "ii" "ipc" "call" "altSwitcher" "next"; }
bind "Alt+Shift+Tab" { spawn "qs" "-c" "ii" "ipc" "call" "altSwitcher" "previous"; }
```

---

### region

Region selection tools. Screenshots, OCR, recording. Draw a box, get stuff done.

| Function | Description |
|----------|-------------|
| `screenshot` | Take a region screenshot |
| `search` | Image search (Google Lens) |
| `ocr` | OCR text recognition |
| `record` | Record region (no audio) |
| `recordWithSound` | Record region with audio |

```kdl
bind "Super+Shift+S" { spawn "qs" "-c" "ii" "ipc" "call" "region" "screenshot"; }
bind "Super+Shift+X" { spawn "qs" "-c" "ii" "ipc" "call" "region" "ocr"; }
bind "Super+Shift+A" { spawn "qs" "-c" "ii" "ipc" "call" "region" "search"; }
```

---

### session

Power menu. Logout, suspend, reboot, shutdown. The "I'm done for today" buttons.

| Function | Description |
|----------|-------------|
| `toggle` | Open/close session menu |

```kdl
bind "Super+Shift+E" { spawn "qs" "-c" "ii" "ipc" "call" "session" "toggle"; }
```

---

### lock

Lock screen. For when you need to pretend you're working.

| Function | Description |
|----------|-------------|
| `activate` | Lock the screen |

```kdl
bind "Super+Alt+L" allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "lock" "activate"; }
```

---

### cheatsheet

Keyboard shortcuts reference. For when you forget what you just configured five minutes ago.

| Function | Description |
|----------|-------------|
| `toggle` | Open/close cheatsheet |

```kdl
bind "Super+Slash" { spawn "qs" "-c" "ii" "ipc" "call" "cheatsheet" "toggle"; }
```

---

### settings

Open the settings window. GUI config so you don't have to edit JSON like it's 2005.

| Function | Description |
|----------|-------------|
| `open` | Open settings window |

```kdl
bind "Super+Comma" { spawn "qs" "-c" "ii" "ipc" "call" "settings" "open"; }
```

---

### sidebarLeft

Left sidebar (AI chat, apps).

| Function | Description |
|----------|-------------|
| `toggle` | Open/close left sidebar |

---

### sidebarRight

Right sidebar (quick toggles, notepad, settings).

| Function | Description |
|----------|-------------|
| `toggle` | Open/close right sidebar |

---

### bar

Top bar visibility.

| Function | Description |
|----------|-------------|
| `toggle` | Show/hide bar |

---

### wallpaperSelector

Wallpaper picker grid.

| Function | Description |
|----------|-------------|
| `toggle` | Open/close wallpaper selector |

```kdl
bind "Ctrl+Alt+T" { spawn "qs" "-c" "ii" "ipc" "call" "wallpaperSelector" "toggle"; }
```

---

### mediaControls

Floating media controls panel.

| Function | Description |
|----------|-------------|
| `toggle` | Open/close media controls |

---

### osk

On-screen keyboard.

| Function | Description |
|----------|-------------|
| `toggle` | Show/hide on-screen keyboard |

---

### crosshair

Gaming crosshair overlay. For when the game doesn't give you one and you need that competitive edge.

| Function | Description |
|----------|-------------|
| `toggle` | Toggle crosshair visibility |

---

### zoom

Screen zoom. Accessibility feature, or for reading tiny text without squinting.

| Function | Description |
|----------|-------------|
| `zoomIn` | Increase zoom level |
| `zoomOut` | Decrease zoom level |

---

### brightness

Display brightness control.

| Function | Description |
|----------|-------------|
| `increment` | Increase brightness |
| `decrement` | Decrease brightness |

---

### mpris

Media player control.

| Function | Description |
|----------|-------------|
| `pauseAll` | Pause all players |
| `playPause` | Toggle play/pause |
| `previous` | Previous track |
| `next` | Next track |

---

### osdVolume

On-screen volume indicator.

| Function | Description |
|----------|-------------|
| `trigger` | Show volume OSD |

---

### cliphistService

Clipboard history service. The backend that makes clipboard panel work. You probably don't need to call this directly.

| Function | Description |
|----------|-------------|
| `update` | Refresh clipboard history |

---

### gamemode

Performance mode for gaming. Auto-detects fullscreen apps and disables animations/effects. Can also be toggled manually for those stubborn games that don't go fullscreen properly.

| Function | Description |
|----------|-------------|
| `toggle` | Toggle gamemode on/off |
| `activate` | Force enable gamemode |
| `deactivate` | Force disable gamemode |
| `status` | Print current status to logs |

```kdl
bind "Super+F12" { spawn "qs" "-c" "ii" "ipc" "call" "gamemode" "toggle"; }
```
