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

| Overview & workspaces | Sidebars & widgets |
|:---|:---|
| <img src="./preview1.png" alt="Overview and workspaces on Niri" /> | <img src="./preview2.png" alt="Sidebars, volume, media and widgets" /> |

| Settings & theming |   |
|:---|:---|
| <img src="./preview3.png" alt="Settings window, global search and theming" /> |   |

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

- **Quality‑of‑life bits**  
  Global Settings search with indexed options, unified search bar style (Overview + Settings), integrated notepad in the right sidebar, and a Super‑tap daemon (tap Super → toggle ii overview on Niri).

---

## Requirements

- **Compositor:** Niri 25.08+
- **Shell:** Quickshell ≥ 0.2.0
- **Theming:** Matugen for color generation
- **Optional:** DankMaterialShell (DMS), Python + `python-evdev` for the Super‑tap daemon.

---

## Usage notes

- This is **not** a plug‑and‑play theme; it’s my real config directory.
- Treat it as:
  - a reference if you’re building your own ii‑on‑Niri setup, or
  - a starting point to fork and adapt to your system.

---

## Credits

- **end‑4** for the original illogical‑impulse design and Hyprland dotfiles.
- **Quickshell** developers and community for the widget system this depends on.
