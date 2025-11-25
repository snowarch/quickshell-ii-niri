# Installation Guide

How to get ii running on Niri. This covers dependencies, the install process, and basic verification.

---

## Quick Start (Arch-based)

```bash
git clone https://github.com/snowarch/quickshell-ii-niri.git
cd quickshell-ii-niri
./setup install      # interactive
./setup install -y   # non-interactive
```

The script handles packages, configs, and services. After it finishes:

```bash
niri msg action reload-config
```

For manual installation or other distros, keep reading.

---

## What Gets Installed

### Core (required)

| Package | Purpose |
|---------|---------|
| `niri` | Compositor |
| `quickshell-git` (AUR) | Shell runtime |
| `wl-clipboard`, `cliphist` | Clipboard stack |
| `pipewire`, `wireplumber` | Audio |
| `xdg-desktop-portal-gnome` | File dialogs, screenshare |
| `libnotify` | Notifications |

The AUR version of Quickshell is required. The official repos package is missing Wayland modules like `IdleInhibitor`.

### Qt6 Stack

Quickshell needs these:

```
qt6-declarative qt6-base qt6-svg qt6-5compat qt6-imageformats
qt6-multimedia qt6-wayland qt6-shadertools kirigami
```

Plus `jemalloc`, `libpipewire`, `polkit`, `mate-polkit`.

### Screenshots & Recording

| Tool | Purpose |
|------|---------|
| `grim` | Screenshots |
| `slurp` | Region selection |
| `wf-recorder` | Screen recording |
| `imagemagick` | Image processing |
| `tesseract` | OCR |

### Theming

| Tool | Purpose |
|------|---------|
| `matugen` | Material You colors from wallpaper |
| `mpvpaper` | Video wallpapers |
| `ffmpeg` | Video thumbnails |

Fonts: JetBrains Mono Nerd, Material Symbols, Rubik, Readex Pro, Space Grotesk.

### Optional

These only matter if you use the corresponding features:

- `hyprpicker` - color picker
- `songrec` - music recognition
- `easyeffects` - audio effects toggle
- `warp-cli` - Cloudflare WARP toggle
- `ydotool`, `python-evdev` - Super-tap daemon

---

## Manual Installation

### 1. Install dependencies

Check `sdata/dist-arch/` for the full package lists. Install what you need from your distros repos.

### 2. Clone the config

```bash
git clone https://github.com/snowarch/quickshell-ii-niri.git ~/.config/quickshell/ii
```

Or clone elsewhere and symlink.

### 3. Copy dotfiles

```bash
cp -r dots/.config/* ~/.config/
```

This includes niri config, matugen templates, gtk settings, etc.

### 4. Wire into Niri

Add to `~/.config/niri/config.kdl`:

```kdl
spawn-at-startup "qs" "-c" "ii"
```

If you also run DMS:

```kdl
spawn-at-startup "dms" "run"
```

---

## Verification

After restarting Niri:

```bash
qs log -c ii
```

Check that:

- Bar and background show up
- Alt+Tab cycles windows
- Super opens overview (if using Super-tap daemon)
- Clipboard panel works (bind to `qs ipc -c ii call clipboard toggle`)
- Screenshots work from the overlay or bar

If something breaks, the logs usually point to a missing dependency.

---

## Partial Installation

The setup script supports individual steps:

```bash
./setup install-deps    # packages only
./setup install-setups  # services/groups only
./setup install-files   # config files only
```

Run `./setup help` for all options.
