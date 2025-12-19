# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## What this repo is
A **Quickshell** configuration (“ii on Niri”) that runs as a desktop shell on the **Niri** compositor.

Key entrypoints:
- `shell.qml`: main `ShellRoot` entry.
- `settings.qml` / `waffleSettings.qml`: settings UI (spawned as a separate `qs -n -p ...` process).
- `setup`: installer/updater that syncs this repo into `~/.config/quickshell/ii/`.

## Common commands

### Install / update / rollback
The repo’s `./setup` script is the main workflow for install and updates:

```bash
./setup                 # interactive menu
./setup install          # install deps + system setup + config files
./setup update           # pull + sync QML/scripts/assets into ~/.config/quickshell/ii + restart shell
./setup doctor           # diagnose and auto-fix common issues
./setup rollback         # restore from snapshots created by updates

# also supported (see ./setup -h)
./setup migrate
./setup status
```

Options: `-y/--yes` (skip prompts), `-q/--quiet`, `-h/--help`.

After installing/updating Niri config, reload Niri’s config:

```bash
niri msg action load-config-file
```

IMPORTANT WORKFLOW NOTE: If you edit this repo directly (instead of editing `~/.config/quickshell/ii/`), run `./setup update` to sync your changes into the live Quickshell config directory.

### Run / restart the shell
Run (expects the config to be installed at `~/.config/quickshell/ii/`):

```bash
qs -c ii
```

Restart without restarting Niri:

```bash
qs kill -c ii && qs -c ii
```

View logs:

```bash
qs log -c ii
```

### IPC (for quick manual testing)
From terminal:

```bash
qs -c ii ipc call <target> <function>
```

Docs:
- IPC targets/functions: `docs/IPC.md`
- Default keybinds: `docs/KEYBINDS.md`

Quick IPC target index (grep implementation via `rg -n 'target: "<name>"'`):
- Core: `overview`, `overlay`, `clipboard`, `altSwitcher`, `region`, `session`, `lock`, `settings`, `cheatsheet`, `closeConfirm`
- System: `audio`, `brightness`, `mpris`, `gamemode`, `notifications`, `minimize`, `bar`, `wallpaperSelector`, `mediaControls`, `osk`, `osd`, `osdVolume`, `zoom`
- Waffle-only: `search`, `wactionCenter`, `wnotificationCenter`, `wwidgets`, `wbar`, `taskview`

### QML formatting / linting
There’s a `.qmlformat.ini` in the repo; you can try Qt’s tools if they’re available:

```bash
qmllint shell.qml
qmlformat --inplace shell.qml
```

In practice, runtime smoke-testing is the most reliable check:

```bash
qs kill -c ii && qs -c ii
qs log -c ii
```

### Python deps (region tools, image ops, etc.)
Python deps are listed in `requirements.txt`:

```bash
uv pip install -r requirements.txt
```

One-off helper (used to parse Niri keybinds into JSON for the cheatsheet):

```bash
./scripts/parse_niri_keybinds.py                # reads ~/.config/niri/config.kdl
./scripts/parse_niri_keybinds.py /path/to/config.kdl
```

### Translation tooling
Translation files live under `translations/` and are managed by `translations/tools/manage-translations.sh`:

```bash
translations/tools/manage-translations.sh --help
translations/tools/manage-translations.sh status
translations/tools/manage-translations.sh update
translations/tools/manage-translations.sh update -l zh_CN
translations/tools/manage-translations.sh clean
translations/tools/manage-translations.sh sync
```

## Big-picture architecture

### Startup flow (shell entry)
`shell.qml` is the runtime root:
- Forces instantiation of a few service singletons.
- Waits for `Config.ready` (see `modules/common/Config.qml`).
- Applies theme on config ready via `ThemeService.applyCurrentTheme()`.
- Loads exactly one “panel family” via `LazyLoader`:
  - `ShellIiPanels.qml` when `Config.options.panelFamily !== "waffle"`
  - `ShellWafflePanels.qml` when `Config.options.panelFamily === "waffle"`
- Exposes IPC:
  - `target: "settings"` opens `settings.qml` or `waffleSettings.qml` in a standalone `qs -n -p ...` process.
  - `target: "panelFamily"` cycles/sets the active family.
- Manages animated family switching via `FamilyTransitionOverlay.qml` + `GlobalStates.qml`.

### Panel system: families + enabled panel IDs
Panels are loaded dynamically from two config values:
- `Config.options.panelFamily`: active “style family” (`"ii"` or `"waffle"`).
- `Config.options.enabledPanels`: list of string identifiers.

`ShellIiPanels.qml` and `ShellWafflePanels.qml` are the central mapping layer from identifier → component.

Key detail: each panel is behind a `LazyLoader` gate:
- **must** be in `enabledPanels`, and
- may have an additional `extraCondition` gate (feature toggles, vertical vs horizontal bar, backdrops enabled, etc.).

#### Identifier → component mapping (and important gates)
Material ii (see `ShellIiPanels.qml`):
- `iiBar` → `Bar` (disabled when `Config.options.bar.vertical` is true; use `iiVerticalBar` instead)
- `iiVerticalBar` → `VerticalBar` (only when `Config.options.bar.vertical` is true)
- `iiBackground` → `Background`
- `iiBackdrop` → `Backdrop` (only when `Config.options.background.backdrop.enable` is true)
- `iiDock` → `Dock` (only when `Config.options.dock.enable` is true)
- `iiOverlay` → `Overlay`
- `iiOverview` → `Overview`
- `iiSidebarLeft` → `SidebarLeft`
- `iiSidebarRight` → `SidebarRight`
- `iiRegionSelector` → `RegionSelector`
- `iiWallpaperSelector` → `WallpaperSelector`
- `iiClipboard` → `modules/clipboard/ClipboardPanel.qml`
- plus: `iiCheatsheet`, `iiLock`, `iiMediaControls`, `iiNotificationPopup`, `iiOnScreenDisplay`, `iiOnScreenKeyboard`, `iiPolkit`, `iiScreenCorners`, `iiSessionScreen`

Waffle (see `ShellWafflePanels.qml`):
- `wBar` → `WaffleBar`
- `wBackground` → `WaffleBackground`
- `wBackdrop` → `WaffleBackdrop` (only when `Config.options.waffles.background.backdrop.enable` is true)
- `wStartMenu` → `WaffleStartMenu`
- `wActionCenter` → `WaffleActionCenter`
- `wNotificationCenter` → `WaffleNotificationCenter`
- `wNotificationPopup` → `WaffleNotificationPopup`
- `wOnScreenDisplay` → `WaffleOSD`
- `wWidgets` → `WaffleWidgets` (only when `Config.options.waffles.modules.widgets` is true)
- `wTaskView` → `WaffleTaskView` (experimental; not enabled by default)
- plus: `wLock`, `wPolkit`, `wSessionScreen`

Waffle-specific “always-on routers” when `panelFamily === "waffle"`:
- `modules/waffle/clipboard/WaffleClipboard.qml` is loaded to handle IPC (`target: "clipboard"`) for waffle.
- `modules/waffle/altSwitcher/WaffleAltSwitcher.qml` is loaded to handle IPC (`target: "altSwitcher"`) for waffle.

Panel family defaults and migration:
- Default enabled panels per family are defined in `shell.qml` (`root.panelFamilies`).
- On config ready, `shell.qml` backfills `enabledPanels` if empty and runs a migration to ensure waffle uses `wBackdrop` instead of `iiBackdrop`.

#### Where to edit what (common module/panel tasks)
- Add/rename a panel identifier or change its gating condition:
  - `ShellIiPanels.qml` (Material ii mapping + `extraCondition` gates)
  - `ShellWafflePanels.qml` (Waffle mapping + waffle-only always-on routers)
- Change which panels are enabled by default (first run / empty config):
  - `shell.qml` (`root.panelFamilies`)
- Change how family switching behaves (animation, ensuring base panels, migration):
  - `shell.qml` (`cyclePanelFamily`, `setPanelFamily`, transition overlay, `migrateEnabledPanels`, `_ensureFamilyPanels`)
- Change IPC routing/targets:
  - per-feature modules usually define their own `IpcHandler` (e.g. `modules/regionSelector/RegionSelector.qml`, `modules/ii/overlay/Overlay.qml`, `modules/sidebarLeft/SidebarLeft.qml`)
  - family-level routing lives in `shell.qml` (`target: "settings"`, `target: "panelFamily"`) and waffle-only router modules (`modules/waffle/clipboard/WaffleClipboard.qml`, `modules/waffle/altSwitcher/WaffleAltSwitcher.qml`)

This pattern is intentional:
- Most UI work lives in `modules/`.
- Most backend state/IO lives in `services/` singletons.

### Module architecture (how most panels are built)
Most panel modules follow a common shape:
- A top-level `Scope {}` (Quickshell) that owns state and IPC.
- One or more `PanelWindow {}` instances created either:
  - per-monitor via `Variants { model: Quickshell.screens ... }` (e.g. bars and overview), or
  - as a single overlay window toggled by a `Loader`/`LazyLoader`.
- Visibility is usually driven by a `GlobalStates.*Open` boolean (instead of creating/destroying windows directly).
- “Click outside to close” behavior is handled by:
  - `CompositorFocusGrab` (Hyprland-only), plus
  - a fallback full-screen `MouseArea` hit-test on Niri.

Concrete examples:
- Bar (Material ii): `modules/bar/Bar.qml` creates a per-screen `PanelWindow` under `WlrLayershell.namespace: "quickshell:bar"` and supports auto-hide behavior.
- Overview: `modules/overview/Overview.qml` is a full-screen overlay per screen and integrates with compositor state (`CompositorService` + `NiriService`).
- Overlay: `modules/ii/overlay/Overlay.qml` keeps the window loaded for instant open and uses a `mask` region based on `OverlayContext.clickableWidgets`.
- Sidebars: `modules/sidebarLeft/SidebarLeft.qml` and `modules/sidebarRight/SidebarRight.qml` are panel windows that toggle via IPC and close-on-backdrop-click.
- Region tools: `modules/regionSelector/RegionSelector.qml` is per-screen, driven by `GlobalStates.regionSelectorOpen` and exposes IPC functions (`region.screenshot/search/ocr/record/...`).

### Waffle family modules (Windows 11-style)
The waffle family is still the same shell process, but uses its own panel windows and state flags. Most waffle panels follow:
- A full-screen click-outside overlay window + the actual panel window.
- `GlobalStates.<wafflePanel>Open` booleans for visibility.

Examples:
- Start menu: `modules/waffle/startMenu/WaffleStartMenu.qml` (IPC target: `search`).
- Action center: `modules/waffle/actionCenter/WaffleActionCenter.qml` (IPC target: `wactionCenter`).
- Taskbar: `modules/waffle/bar/WaffleBar.qml` (IPC target: `wbar`).

The core “look & feel” building blocks for waffle live under `modules/waffle/looks/` (acrylic rectangles, Fluent icons, W* widgets), and are widely reused by waffle submodules.

### Config system (JSON-backed singleton)
`modules/common/Config.qml` is a `pragma Singleton` that:
- Persists JSON via `Quickshell.Io.FileView` + a large `JsonAdapter` schema.
- Exposes the live config object as `Config.options`.

The setup docs describe on-disk destinations:
- QML code: `~/.config/quickshell/ii/`
- User config JSON: `~/.config/illogical-impulse/config.json` (see `docs/SETUP.md`)

### Compositor integration (Niri + remnants of Hyprland support)
Compositor detection/switching is centralized in `services/CompositorService.qml`.

Niri integration is primarily in `services/NiriService.qml`:
- Reads `NIRI_SOCKET` and uses `DankSocket` to subscribe to Niri’s event stream.
- Calls `niri msg -j outputs` for output metadata.

If you’re touching anything workspace/window-related (overview, task switchers, workspace indicators), start with:
- `services/NiriService.qml`
- `services/CompositorService.qml` (sorting and compositor abstraction)

### Backend services (selected map)
Most “backend” logic lives under `services/` as `pragma Singleton`s. Common patterns:
- **Integration via Quickshell services**: `Quickshell.Services.Pipewire`, `Quickshell.Services.Notifications`, `Quickshell.Services.SystemTray`.
- **Side effects via `Process` / `execDetached`** for calling system tools (`niri msg`, `swayidle`, `cliphist`, `ddcutil`, etc.).
- **Persistence via `Quickshell.Io.FileView`** for small state files (notifications history, gamemode state, etc.).

Key nodes:
- `services/CompositorService.qml`: detects compositor and provides `sortedToplevels` (with a “sorting consumer” gate so expensive sorting runs only while UIs like overview are open).
- `services/NiriService.qml`: subscribes to Niri’s event stream + exposes actions by sending JSON IPC to `NIRI_SOCKET` (e.g. `focusWindow`, `switchToWorkspace`, `moveWindowToWorkspace`, `toggleOverview`).
- `services/TrayService.qml`: wraps `SystemTray` items with pin/filter logic and “smart activate” workarounds; on Niri it can start `xembedsniproxy` for XEmbed tray items.
- `services/Notifications.qml`: wraps `NotificationServer` with persistence + grouping + popup timers; DND is `Config.options.notifications.silent`; can focus/launch an app when a “view/open” action is invoked.
- `services/Audio.qml`: wraps PipeWire default sink/source; implements “volume protection” (max cap + max increment) and ramps slider jumps; exposes IPC `target: "audio"`.
- `services/Brightness.qml`: per-screen brightness controller (brightnessctl + ddcutil) + optional “anti-flashbang” dimming; exposes IPC `target: "brightness"`.
- `services/Wallpapers.qml`: wallpaper folder browsing + apply via the existing switchwall scripts + thumbnail generation (used by `modules/wallpaperSelector/*`).
- `services/Cliphist.qml`: cliphist integration (read/list/delete/wipe) + fuzzy search + “superpaste”; exposes IPC `target: "cliphistService"`.
- `services/LauncherSearch.qml`: debounced omnibox logic (prefix parsing, actions, math via `qalc`, web search, apps via `AppSearch`, clipboard via `Cliphist`).
- `services/AppSearch.qml`: fuzzy app search over `DesktopEntries` + icon guessing/substitutions.
- `services/KeyringStorage.qml` + `services/Ai.qml` (+ `services/ai/*`): keyring-backed API keys (`secret-tool`) and multi-provider chat (Gemini/OpenAI/Mistral API strategies).
- `services/Idle.qml`: manages `swayidle` timeouts (screen off, lock, suspend) and a persisted “inhibit” flag.
- `services/Updates.qml`: Arch-only update count via `checkupdates`.
- `services/GameMode.qml`: fullscreen detection (Niri) that disables effects/animations and can toggle Niri animations by editing `~/.config/niri/config.kdl`.

### Theme / Material You pipeline
Theme selection is orchestrated by `services/ThemeService.qml`:
- Reads `Config.options.appearance.theme`.
- `"auto"` delegates to `services/MaterialThemeLoader.qml`.
- Non-auto themes apply via `ThemePresets.applyPreset(...)`.

`services/MaterialThemeLoader.qml` watches the generated material theme JSON and writes colors into the `Appearance` singleton.

### Setup/update mechanics (how changes reach a running system)
`./setup update`:
- Optionally pulls remote changes.
- Syncs `*.qml` + `modules/`, `services/`, `scripts/`, `assets/`, `translations/` into `~/.config/quickshell/ii/`.
- Restarts the shell when it’s running in a graphical session.
- Creates snapshots so `./setup rollback` can restore a previous working state.

If you change code and don’t see it reflected at runtime:
- Ensure you’re editing the files actually being loaded (either develop directly in `~/.config/quickshell/ii/`, or run `./setup update` to sync).
- Restart the shell: `qs kill -c ii && qs -c ii`.

### Autostart (user systemd units)
The autostart system is implemented in `services/Autostart.qml` and can:
- Launch `.desktop` entries via `gtk-launch`.
- Launch shell commands (`bash -lc ...`).
- Manage per-user systemd units under `~/.config/systemd/user/`.

Important implementation notes for contributors:
- Desktop autostart launches are queued/serialized to avoid races from reusing a single `Process`.
- Unit creation is serialized to avoid races between directory creation, file writes, and `systemctl --user daemon-reload` / `enable --now`.
- Unit deletion avoids shell interpolation and only deletes units that contain the `# ii-autostart` marker header.
- Deletion operations are also serialized to avoid overlapping `systemctl` operations.

### Window previews (TaskView)
TaskView window thumbnails are managed by `services/WindowPreviewService.qml`.

Implementation notes for contributors:
- The on-disk cache lives under `${XDG_CACHE_HOME}/ii-niri/window-previews` (see `previewDir`).
- On startup/initialization, the cache is rebuilt from disk using a `FolderListModel` so we can use each file’s real `fileModified` time as the cache timestamp.
  - This avoids treating old previews as “fresh” after a shell restart.
- Cache rebuilds are debounced to avoid thrashing when many previews are created at once.

## Repo layout (high level)
- `modules/`: UI modules (Material ii + Waffle family modules live under separate namespaces).
- `services/`: singleton backends (compositor state, theming, notifications, clipboard integration, etc.).
- `scripts/`: helper scripts invoked by modules/services.
- `sdata/`: setup implementation (shared libs in `sdata/lib/`, migrations in `sdata/migrations/`, Arch package lists in `sdata/dist-arch/`).
- `defaults/`: default/preset resources (e.g. AI prompt presets in `defaults/ai/`).
- `translations/`: translation JSON + tooling.
- `dots/`: config files that `./setup install` can copy into `~/.config/` (Niri config, matugen templates, etc.).

## Other docs worth knowing exist
- `docs/LIMITATIONS.md`: compositor/feature caveats (Niri vs inherited Hyprland behaviors).
- `docs/OPTIMIZATION.md`: repo-specific QML/Quickshell performance notes (typed props, qualified lookups, LazyLoader semantics).
- `docs/VESKTOP.md`: how Vesktop/Discord theming regen works + manual regen commands.

## Project-specific preferences
- Prefer that **Waybar does not autostart** when KDE starts (avoid adding Waybar autostart changes under `dots/` unless explicitly requested).
