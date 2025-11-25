# Installing quickshell-ii on Niri

This document explains what you need to run this shell on **Niri**, what each feature depends on, and how to wire it into your session in a predictable way.

It assumes you are comfortable with a terminal and your distro's package manager.

## 0. Quick install (Arch-based systems)

If you're on an Arch-based system (for example Arch Linux, EndeavourOS, CachyOS) and just want ii running on Niri, you can let the installer handle the boring bits:

```bash
curl -fsSL https://raw.githubusercontent.com/snowarch/quickshell-ii-niri/main/install.sh | bash
```

The script will:

**Core (always installed):**
- **Niri** compositor
- **Quickshell** from AUR (`quickshell-git`) with all required Qt6 dependencies
- Basic utilities: `cliphist`, `wl-clipboard`, `libnotify`, `jq`, `ripgrep`, etc.
- XDG portals: `xdg-desktop-portal`, `xdg-desktop-portal-gtk`, `xdg-desktop-portal-gnome`
- Audio: PipeWire stack, WirePlumber, playerctl

**Optional (prompted):**
- **Toolkit**: `ydotool`, `wtype`, `python-evdev` for input simulation and on-screen keyboard
- **Screenshots/Recording**: `grim`, `slurp`, `wf-recorder`, `tesseract`, `swappy`
- **Widgets**: `fuzzel`, `hyprpicker`, `songrec`, `translate-shell`
- **Fonts/Theming**: Matugen, JetBrains Mono Nerd, Material Symbols, Roboto Flex, etc.
- **Python deps**: `python-pillow`, `python-opencv` for the evdev daemon
- **Icon themes**: WhiteSur icons, Capitaine cursors
- **Super-tap daemon**: tap Super key to toggle overview

> **Important:** This installer uses `quickshell-git` from AUR, not the official `quickshell` package from the Arch repos. The AUR version includes all the Wayland modules (like `IdleInhibitor`) that ii needs.

After it finishes, restart Niri or reload the config:

```bash
niri msg action reload-config
```

If you are on a non-Arch distro, or you prefer to manage packages by hand, use the rest of this document as a guide.

---

## 1. Overview

This repo is a Quickshell configuration called **ii**. On Niri it provides:

- Bar + sidebars, overview and overlay widgets
- Backdrop blurred wallpaper layer (separate from the main wallpaper)
- Wallpaper selector and quick wallpaper grid
- Region screenshot, OCR and image search
- Region and fullscreen recording
- Autostart / systemd helpers
- Optional integrations: EasyEffects, Cloudflare WARP, music recognition, AI helpers, etc.

Some dependencies are **hard requirements**, others are optional and only affect specific features.

---

## 2. Dependency matrix

### 2.1 Core (required)

These must be present for ii to behave as a shell on Niri.

| Area              | Tool / Package                | Used for                                          |
|-------------------|-------------------------------|---------------------------------------------------|
| Compositor        | `niri`                        | Window management, focus, outputs                 |
| Shell             | `quickshell-git` (AUR)        | Running ii (`qs -c ii`)                          |
| Qt6 deps          | See list below                | Quickshell runtime dependencies                   |
| Clipboard         | `wl-clipboard`                | `wl-copy`, `wl-paste`                             |
| Clipboard history | `cliphist`                    | Persistent clipboard history                      |
| Notifications     | `libnotify` / `notify-send`   | User-facing notifications                         |
| Audio             | PipeWire + WirePlumber        | Volume UI & system sounds                         |
| XDG portals       | `xdg-desktop-portal-gtk/gnome`| File dialogs, screen sharing                      |

**Important:** You must use `quickshell-git` from AUR, not `quickshell` from the official repos. The official package does not include all the Wayland modules (like `Quickshell.Wayland.IdleInhibitor`) that ii needs.

**Qt6 dependencies for Quickshell:**
```
qt6-declarative qt6-base qt6-svg qt6-5compat qt6-imageformats qt6-multimedia
qt6-positioning qt6-quicktimeline qt6-sensors qt6-tools qt6-translations
qt6-virtualkeyboard qt6-wayland qt6-shadertools qt6-quick3d
kirigami kdialog syntax-highlighting
jemalloc libpipewire libxcb wayland libdrm mesa polkit mate-polkit
```

**AUR dependencies:**
```
google-breakpad qt6-avif-image-plugin quickshell-git
```

**Theming dependencies:**
```
adw-gtk-theme-git whitesur-icon-theme-git capitaine-cursors breeze-plus darkly-bin
matugen-bin ttf-jetbrains-mono-nerd ttf-material-symbols-variable-git
ttf-rubik-vf ttf-readex-pro otf-space-grotesk
```

**Backlight control:**
```
brightnessctl ddcutil geoclue
```

If any of the above is missing, core UI will be broken or heavily degraded.

---

### 2.2 Recommended stack ("full shell" experience)

#### Screenshots, region tools and recording

Used by: region selector, overlay recorder widget, bar screen-snip and record buttons.

| Tool         | Purpose                                           |
|--------------|---------------------------------------------------|
| `grim`       | Base screenshots and temporary captures           |
| `slurp`      | Interactive region selection                      |
| `wf-recorder`| Region and fullscreen recording                   |
| `pactl`      | Find PipeWire monitor/source for audio capture    |
| `imagemagick` (`magick`, `identify`) | Crop regions, generate thumbnails |
| `wl-clipboard` | Pipe images/text into the clipboard             |

#### Theming, Material You and video wallpapers

Used by: wallpaper pipeline (`scripts/colors/switchwall.sh`), `Background.qml`, `Backdrop.qml`, `MaterialThemeLoader`.

| Tool      | Purpose                                             |
|-----------|-----------------------------------------------------|
| `matugen` | Generate Material You palettes from an image or color |
| `jq`      | Read/write ii config JSON and other JSON blobs      |
| `gsettings` | Sync GNOME/GTK color-scheme and theme (optional but used) |
| `mpvpaper` | Draw video wallpapers behind Niri workspaces        |
| `ffmpeg`  | Extract first-frame thumbnails from video wallpapers |

#### Thumbnails

Used by: wallpaper selector (GridView), quick wallpaper grid in settings.

| Tool / script                                  | Purpose                              |
|------------------------------------------------|--------------------------------------|
| `scripts/thumbnails/generate-thumbnails-magick.sh` | Generate Freedesktop-compliant thumbnails with `magick` |
| `scripts/thumbnails/thumbgen-venv.sh` + Python venv | Bulk thumbnail generation via `thumbgen.py` |

> If these tools are missing, ii will fall back to loading full images. Performance may degrade, but the selector still works thanks to built-in fallbacks in `ThumbnailImage.qml`.

---

### 2.3 Optional feature sets

You can install these only if you care about the corresponding features.

#### Region OCR and image search

Used by: RegionSelector actions for OCR/search.

| Tool       | Purpose                                   |
|------------|-------------------------------------------|
| `tesseract`| OCR on cropped regions                    |
| `curl`     | Upload image to search endpoint           |
| `jq`       | Parse search API responses                |
| `xdg-open` | Open browser with the search URL          |

#### Color picker and quick toggles

Used by: bar utility buttons and quick toggles panel.

| Feature          | Tool(s)                   |
|------------------|---------------------------|
| Color picker     | `hyprpicker`              |
| Mic toggle       | `wpctl`                   |
| Game mode (Hyprland) | `hyprctl`, `jq`       |
| EasyEffects      | `easyeffects` **or** Flatpak `com.github.wwmm.easyeffects` |
| Cloudflare WARP  | `warp-cli`                |
| Music recognition| `songrec`                 |

All of these are optional. If a dependency is missing, only that specific toggle or panel stops working.

#### AI and translations

Used by: Gemini-powered UI translation and wallpaper categorisation.

| Feature                  | Tool(s)                          |
|--------------------------|----------------------------------|
| UI translation (Gemini)  | `curl`, `jq`, `secret-tool`, `notify-send` |
| Wallpaper categorisation | Same as above                    |
| Ollama helpers           | `ollama`                         |
| Python venv (`$ILLOGICAL_IMPULSE_VIRTUAL_ENV`) | For `find_regions.py`, `thumbgen.py`, `scheme_for_image.py` |

If you dont configure an AI key or Python env, ii will still run; these features simply remain idle.

#### Autostart and systemd helpers

Used by: Autostart service & Settings UI for user services.

| Tool        | Purpose                              |
|-------------|--------------------------------------|
| `systemctl` | Manage `--user` services and targets |

Optional: if `systemd --user` isnt used, the Autostart page becomes mostly informational.

---

## 3. Example installation on Arch Linux

This is **only an example** for Arch Linux and Arch-based derivatives. Adjust package names to match your distribution.

### 3.1 Core

```bash
sudo pacman -S --needed \
  niri quickshell wl-clipboard cliphist libnotify \
  pipewire pipewire-pulse pipewire-alsa pipewire-jack
```

### 3.2 Recommended tools

```bash
sudo pacman -S --needed \
  grim slurp wf-recorder imagemagick swappy tesseract jq curl xdg-utils \
  matugen mpvpaper ffmpeg hyprpicker \
  networkmanager nm-connection-editor \
  easyeffects warp-cli songrec
```

You can comment out packages you dont care about (for example `warp-cli` if you never use WARP).

For the Python virtual environment referenced by `$ILLOGICAL_IMPULSE_VIRTUAL_ENV`, create a venv and install whatever dependencies `find_regions.py`, `thumbgen.py` and `scheme_for_image.py` require. This environment is only used for advanced thumbnailing and color-scheme detection.

---

## 4. Installing the ii configuration

You can install ii directly into Quickshells config directory, or keep it in a separate workspace and symlink it.

### Option A: Directly into `~/.config/quickshell/ii`

```bash
git clone https://github.com/snowarch/quickshell-ii-niri.git \
  ~/.config/quickshell/ii
```

### Option B: Workspace checkout

```bash
mkdir -p ~/quickshell-workspace
cd ~/quickshell-workspace
git clone https://github.com/snowarch/quickshell-ii-niri.git ii

# Optional: link into ~/.config
ln -s ~/quickshell-workspace/ii ~/.config/quickshell/ii
```

---

## 5. Wiring ii into Niri

In `~/.config/niri/config.kdl` make sure ii is started at login:

```kdl
// Shells
spawn-at-startup "qs" "-c" "ii"
```

If you also use DMS and want it in the same session:

```kdl
spawn-at-startup "dms" "run"
```

Restart Niri to apply changes.

---

## 6. Verifying your setup

After logging in or restarting the compositor:

1. Check ii logs:

   ```bash
   qs log -c ii
   ```

2. Confirm that:
   - The bar and background appear.
   - The backdrop layer can be enabled from Settings.
   - Alt+Tab and other keybindings trigger ii modules (overview, overlay, clipboard, etc.).
   - Screen snip and recording work from both the overlay and the bar.
   - The wallpaper selector opens and displays images.

If a specific feature fails, cross-check its dependencies in the matrix above.

---
Work in progress..
