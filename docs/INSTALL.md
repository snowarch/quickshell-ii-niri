# Installation Guide

---

## Quick Start (Arch-based)

```bash
git clone https://github.com/snowarch/quickshell-ii-niri.git
cd quickshell-ii-niri
./setup install      # interactive
./setup install -y   # non-interactive
```

After it finishes:

```bash
niri msg action reload-config
```

---

## Manual Installation

### 1. Install dependencies

See [PACKAGES.md](PACKAGES.md) for the full list. The essentials:

- `niri` - compositor
- `quickshell-git` (AUR) - shell runtime (not the official `quickshell` package)
- `wl-clipboard`, `cliphist` - clipboard
- `pipewire`, `wireplumber` - audio
- `grim`, `slurp` - screenshots
- `matugen` - theming

### 2. Clone

```bash
git clone https://github.com/snowarch/quickshell-ii-niri.git ~/.config/quickshell/ii
```

### 3. Copy configs

```bash
cp -r dots/.config/* ~/.config/
```

### 4. Add to Niri

In `~/.config/niri/config.kdl`:

```kdl
spawn-at-startup "qs" "-c" "ii"
```

---

## Verification

```bash
qs log -c ii
```

- Bar and background should appear
- Alt+Tab should cycle windows
- `Super+V` opens clipboard
- `Super+Shift+S` takes a screenshot

---

## More Info

- [PACKAGES.md](PACKAGES.md) - Full package list by category
- [SETUP.md](SETUP.md) - How the setup script works, update/uninstall info
- [KEYBINDS.md](KEYBINDS.md) - Default keyboard shortcuts
- [IPC.md](IPC.md) - All IPC targets for custom bindings
