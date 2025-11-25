# illogical-impulse (ii) on Niri

<div align="center">
  <h3>My Quickshell shell fork of end‑4's ii, adapted for the Niri compositor</h3>
</div>

---

## Overview

- Runs the illogical‑impulse (ii) shell on **Niri** instead of Hyprland.
- Designed to live **alongside DankMaterialShell (DMS)** in the same session.
- Heavy personal customization; this repo mirrors my live `~/.config/quickshell/ii`.
- Work in progress: I change things often and don’t promise stability.

---

## Screenshots

All screenshots are taken from my actual Niri session with this config:

| Workspaces | Overview |
|:---|:---|
| <img width="1920" height="1080" src="https://github.com/user-attachments/assets/9faaad0e-a665-4747-9428-ea94756e1f0f" alt="Overview and workspaces on Niri" /> | <img width="1918" height="1080" src="https://github.com/user-attachments/assets/21e43f3e-d6d9-4625-8210-642f9c05509b" alt="Sidebars, volume, media and widgets" /> |

| Overlay | Settings UI · Sidebar |
|:---|:---|
| <img width="1912" height="1080" src="https://github.com/user-attachments/assets/25700a1c-70e6-4456-b053-35cf83fcac7a" alt="Settings window, global search and theming" /> | <img width="1920" height="1080" src="https://github.com/user-attachments/assets/1d5ca0f0-6ffb-46da-be1a-2d5e494089e7" alt="Settings UI" /> |

---

## Features

- **Niri-aware compositor layer**  
  `CompositorService` + `NiriService` track workspaces, windows, outputs, overview and keyboard layouts using `NIRI_SOCKET`.

- **Overview tuned for Niri**  
  Dedicated `OverviewNiriWidget` with a grid of workspaces based on Niri’s scrolling layout, drag & drop of windows between workspaces, and a context panel with live preview + quick actions (focus / close).

- **Custom Alt‑Tab (AltSwitcher)**  
  Overlay panel that cycles Niri windows (all workspaces) using MRU order, with configurable animation and monochrome icons.

- **Wallpaper + theming pipeline**  
  Matugen‑driven Material You colors, dynamic blur/dim of the wallpaper based on windows on the current workspace, and colors shared with ii, DMS and apps.

- **Clipboard history panel**  
  Built‑in cliphist‑based history popup with search, previews and copy/paste/delete actions, which you can bind to something like Super+V if you want it fully integrated into Niri.

- **Quality‑of‑life bits**  
  Global Settings search with indexed options, unified search bar style (Overview + Settings), integrated notepad in the right sidebar, and a Super‑tap daemon (tap Super → toggle ii overview on Niri).

---

## Requirements

- **Compositor:** Niri 25.08+
- **Shell:** Quickshell ≥ 0.2.0
- **Theming:** Matugen for color generation
- **Clipboard tools:** `cliphist` (or compatible) + `wl-copy` / `wl-paste` (wl-clipboard), optionally `ydotool` if you want superpaste-style key injection.
- **Optional:** DankMaterialShell (DMS), Python + `python-evdev` for the Super-tap daemon.

---

## Installation

The short version:

1. Clone this repo as your ii config:

   ```bash
   git clone https://github.com/snowarch/quickshell-ii-niri.git \
     ~/.config/quickshell/ii
   ```

2. In `~/.config/niri/config.kdl`, make sure Niri starts ii:

   ```kdl
   spawn-at-startup "qs" "-c" "ii"
   ```

3. Restart Niri.

For a full breakdown of external tools (recording, OCR, EasyEffects, WARP, AI, etc.) and an Arch example of required packages, see **`docs/INSTALL.md`** in this repo.

---

## Usage notes

- This is **not** a plug‑and‑play theme; it’s my real config directory.
- Treat it as:
  - a reference if you’re building your own ii‑on‑Niri setup, or
  - a starting point to fork and adapt to your system.
- To use the clipboard history panel like a Super+V menu, point a Niri keybind at the ii IPC target `clipboard.toggle` (same pattern you would use for `overview.toggle`).

---

## Credits

- **end‑4** for the original illogical‑impulse design and Hyprland dotfiles.
- **Quickshell** developers and community for the widget system this depends on.
