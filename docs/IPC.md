# IPC Reference

ii exposes IPC targets that you can call from Niri keybinds or scripts. The syntax is:

```bash
qs -c ii ipc call <target> <function>
```

Or in Niri config:

```kdl
bind "Key" { spawn "qs" "-c" "ii" "ipc" "call" "<target>" "<function>"; }
```

---

## Available Targets

### overview

Toggle the workspace overview panel.

| Function | Description |
|----------|-------------|
| `toggle` | Open/close overview |

```kdl
bind "Mod+Space" { spawn "qs" "-c" "ii" "ipc" "call" "overview" "toggle"; }
```

---

### overlay

The central overlay with search, quick actions, and widgets.

| Function | Description |
|----------|-------------|
| `toggle` | Open/close overlay |

```kdl
bind "Super+G" { spawn "qs" "-c" "ii" "ipc" "call" "overlay" "toggle"; }
```

---

### clipboard

Clipboard history panel (cliphist-based).

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

Alt+Tab window switcher.

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

Region selection tools for screenshots, OCR, and recording.

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

Power/session menu (logout, suspend, reboot, shutdown).

| Function | Description |
|----------|-------------|
| `toggle` | Open/close session menu |

```kdl
bind "Super+Shift+E" { spawn "qs" "-c" "ii" "ipc" "call" "session" "toggle"; }
```

---

### lock

Lock screen.

| Function | Description |
|----------|-------------|
| `activate` | Lock the screen |

```kdl
bind "Super+Alt+L" allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "lock" "activate"; }
```

---

### cheatsheet

Keyboard shortcuts reference.

| Function | Description |
|----------|-------------|
| `toggle` | Open/close cheatsheet |

```kdl
bind "Super+Slash" { spawn "qs" "-c" "ii" "ipc" "call" "cheatsheet" "toggle"; }
```

---

### settings

Open the settings window.

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

Gaming crosshair overlay.

| Function | Description |
|----------|-------------|
| `toggle` | Toggle crosshair visibility |

---

### zoom

Screen zoom (accessibility).

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

Clipboard history service.

| Function | Description |
|----------|-------------|
| `update` | Refresh clipboard history |
