# Package Reference

Complete list of packages used by ii, organized by category. These are what the setup script installs on Arch-based systems.

The PKGBUILDs live in `sdata/dist-arch/`.

---

## Core (`ii-niri-core`)

Essential packages for Niri + ii to function.

| Package | Purpose |
|---------|---------|
| `niri` | Compositor |
| `bc` | Math in scripts |
| `coreutils` | Basic utils |
| `cliphist` | Clipboard history |
| `curl` | HTTP requests |
| `wget` | Downloads |
| `ripgrep` | Fast search |
| `jq` | JSON parsing |
| `xdg-user-dirs` | User directories |
| `rsync` | File sync |
| `git` | Version control |
| `wl-clipboard` | Wayland clipboard |
| `libnotify` | Notifications |
| `xdg-desktop-portal` | XDG portal base |
| `xdg-desktop-portal-gtk` | GTK portal |
| `xdg-desktop-portal-gnome` | GNOME portal (screenshare) |
| `polkit` | Privilege elevation |
| `mate-polkit` | Polkit agent |
| `networkmanager` | Network management |
| `gnome-keyring` | Secrets storage |
| `dolphin` | File manager |
| `foot` | Terminal |
| `gum` | TUI for setup script |

---

## Quickshell (`ii-niri-quickshell`)

Qt6 stack and Quickshell runtime.

### From official repos

| Package | Purpose |
|---------|---------|
| `qt6-declarative` | QML engine |
| `qt6-base` | Qt core |
| `qt6-svg` | SVG support |
| `qt6-wayland` | Wayland integration |
| `qt6-5compat` | Qt5 compatibility |
| `qt6-imageformats` | Image formats |
| `qt6-multimedia` | Media playback |
| `qt6-positioning` | Geolocation |
| `qt6-quicktimeline` | Timeline animations |
| `qt6-sensors` | Sensor APIs |
| `qt6-tools` | Qt tools |
| `qt6-translations` | Translations |
| `qt6-virtualkeyboard` | Virtual keyboard |
| `jemalloc` | Memory allocator |
| `libpipewire` | PipeWire integration |
| `libxcb` | X11 bridge |
| `wayland` | Wayland libs |
| `libdrm` | DRM/display |
| `mesa` | OpenGL |
| `kirigami` | KDE components |
| `kdialog` | KDE dialogs |
| `syntax-highlighting` | Code highlighting |
| `qt6ct` | Qt6 config tool |
| `kde-gtk-config` | GTK theme sync |
| `breeze` | Breeze theme |

### From AUR

| Package | Purpose |
|---------|---------|
| `quickshell-git` | Quickshell (required) |
| `google-breakpad` | Crash reporting |
| `qt6-avif-image-plugin` | AVIF image support |

---

## Audio (`ii-niri-audio`)

Audio stack and media controls.

| Package | Purpose |
|---------|---------|
| `pipewire` | Audio server |
| `pipewire-pulse` | PulseAudio compat |
| `pipewire-alsa` | ALSA compat |
| `pipewire-jack` | JACK compat |
| `wireplumber` | Session manager |
| `playerctl` | Media player control |
| `libdbusmenu-gtk3` | Tray menus |
| `pavucontrol` | Volume control GUI |

---

## Screenshots & Recording (`ii-niri-screencapture`)

Region tools dependencies.

| Package | Purpose |
|---------|---------|
| `grim` | Screenshots |
| `slurp` | Region selection |
| `swappy` | Screenshot editor |
| `tesseract` | OCR engine |
| `tesseract-data-eng` | English OCR data |
| `wf-recorder` | Screen recording |
| `imagemagick` | Image processing |
| `ffmpeg` | Video processing |

---

## Input Toolkit (`ii-niri-toolkit`)

Input simulation, hardware control, and idle management.

| Package | Purpose |
|---------|---------|
| `upower` | Power management |
| `wtype` | Wayland typing |
| `ydotool` | Input simulation |
| `python-evdev` | Evdev bindings |
| `python-pillow` | Image processing |
| `brightnessctl` | Backlight control |
| `ddcutil` | DDC/CI for monitors |
| `geoclue` | Geolocation |
| `swayidle` | Idle management (screen off, lock, suspend) |

---

## Fonts & Theming (`ii-niri-fonts`)

Fonts, theming, and utilities.

### From official repos

| Package | Purpose |
|---------|---------|
| `fontconfig` | Font configuration |
| `ttf-dejavu` | DejaVu fonts |
| `ttf-liberation` | Liberation fonts |
| `fuzzel` | Application launcher |
| `glib2` | GLib utilities |
| `translate-shell` | Translation CLI |
| `kvantum` | Qt theming |

### From AUR

| Package | Purpose | Required |
|---------|---------|----------|
| `matugen-bin` | Material You colors | Yes |
| `ttf-jetbrains-mono-nerd` | JetBrains Mono Nerd | Yes (monospace) |
| `ttf-material-symbols-variable-git` | Material icons | Yes (UI icons) |
| `ttf-readex-pro` | Readex Pro font | No (has fallback) |
| `ttf-rubik-vf` | Rubik variable font | No (has fallback) |
| `otf-space-grotesk` | Space Grotesk font | No (has fallback) |
| `ttf-twemoji` | Twitter emoji | No (has fallback) |
| `adw-gtk-theme-git` | Adwaita GTK theme | Yes |
| `capitaine-cursors` | Capitaine cursor theme | Yes |
| `hyprpicker` | Color picker | Yes |
| `xwayland-satellite` | Xwayland helper for legacy apps | Yes |
| `songrec` | Music recognition | No |

> **Note:** Optional fonts will be downloaded directly from GitHub if AUR packages are unavailable (e.g., due to regional restrictions). The UI will use system fallback fonts if installation fails completely.

---

## Optional

Not installed by default, but useful.

| Package | Purpose |
|---------|---------|
| `cava` | Audio visualizer (in ii-niri-audio) |
| `easyeffects` | Audio effects |
| `warp-cli` | Cloudflare WARP |
| `ollama` | Local LLM |
| `mpvpaper` | Video wallpapers |
