# Niri-Specific Notes

> This shell was originally made for Hyprland, then butchered to work on Niri. Most things work the same, but there are differences worth knowing about.

---

## What's Different

### Workspaces

**Hyprland**: Traditional numbered workspaces (1-10). You switch between them.

**Niri**: Infinite horizontal scrolling workspace model. You scroll through them like a timeline.

The overview adapts automatically. When you press `Mod+Space`, you get a grid view that makes sense for Niri's scrolling model instead of trying to show you 10 static workspaces.

### Keybindings

**Hyprland**: Uses Quickshell's `GlobalShortcut` QML component. The shell registers shortcuts directly.

**Niri**: Keybindings live in `~/.config/niri/config.kdl`. The compositor handles them and calls the shell via IPC.

All the default keybinds are already set up in `defaults/niri/config.kdl` and get installed when you run `./setup install`. You don't need to do anything.

If you want to change them, edit `~/.config/niri/config.kdl` and reload:

```bash
niri msg action reload-config
```

See [IPC.md](IPC.md) for all available targets you can bind.

### Window Management

**Hyprland**: Floating and tiled windows. Layer shell info. Workspace-specific filtering.

**Niri**: Everything is tiled. No floating. No layer shell queries exposed.

The shell detects this automatically via `CompositorService.isNiri` and uses `NiriService.windows` instead of `HyprlandData.windowList`. The region selector, overview, and Alt+Tab all adapt.

### Display Scaling

**Hyprland**: Per-monitor scaling via `HyprlandMonitor.scale`.

**Niri**: Per-output scaling via `NiriService.displayScales[screen.name]`.

The shell handles both. Your HiDPI setup will work fine.

---

## What Works

Everything that matters:

- ✅ **Overview** - `Mod+Space` opens the workspace grid, adapted for scrolling workspaces
- ✅ **Alt+Tab** - Window switcher works across all workspaces
- ✅ **Region tools** - Screenshots (`Super+Shift+S`), OCR (`Super+Shift+X`), image search (`Super+Shift+A`)
- ✅ **Sidebars** - AI chat, quick toggles, notepad, all that stuff
- ✅ **Clipboard** - History panel with search (`Super+V`)
- ✅ **Wallpaper theming** - matugen generates colors from your wallpaper
- ✅ **Lock screen** - PAM authentication, keyring unlock
- ✅ **Media controls** - MPRIS integration for play/pause/next/previous

---

## What Doesn't Work

Things that are Hyprland-specific and can't be ported:

- ❌ **Layer shell queries** - Niri doesn't expose this info. The region selector can't highlight layer surfaces (like the bar or sidebars) as separate targets. It only sees windows.
- ❌ **Floating window detection** - Everything is tiled in Niri. The overview doesn't need to handle floating windows differently.
- ❌ **GlobalShortcut registration** - Not a Niri feature. Use Niri keybindings instead (already set up for you).

---

## The Super-Tap Daemon

**What it does**: Lets you tap Super (without holding it) to toggle the overview. Like the Windows key opening the Start menu.

**Do you need it on Niri?** No. Niri has `Mod+Space` bound to toggle the overview by default. That's one key. The daemon adds complexity for minimal benefit.

**Is it installed by default?** No. The installer skips it unless you explicitly enable it:

```bash
II_ENABLE_SUPER_DAEMON=1 ./setup install-setups
```

If you previously had it installed and want to remove it, just run:

```bash
./setup install-setups
```

This will stop/disable the service and clean up the helper script.

---

## Configuration

### Niri Config

`~/.config/niri/config.kdl`

This is where keybindings live. The installer copies `defaults/niri/config.kdl` here on first run. Subsequent installs won't overwrite it - new defaults go to `config.kdl.new` so you can diff and merge.

### Shell Config

`~/.config/quickshell/ii/defaults/config.json`

Same as Hyprland. All the shell settings (bar position, sidebar behavior, AI providers, etc.) are here.

### Theming

`~/.config/matugen/config.toml`

Material You color generation from wallpapers. Works the same on both compositors.

---

## Troubleshooting

### Screenshots crash the shell

This was a bug in earlier versions. Fixed now. If you're still seeing crashes:

1. Make sure you're on the latest commit:
   ```bash
   cd ~/quickshell-ii-niri
   git pull
   ./setup update
   ```

2. Check that `grim` is installed:
   ```bash
   pacman -S grim
   ```

3. Check the logs:
   ```bash
   qs log -c ii
   ```

### Keybindings don't work

1. Check your Niri config has the ii keybindings:
   ```bash
   grep "qs.*ipc" ~/.config/niri/config.kdl
   ```

2. Reload Niri config:
   ```bash
   niri msg action reload-config
   ```

3. Make sure Quickshell is running:
   ```bash
   pgrep -a quickshell
   ```

### Overview doesn't show windows

Niri's window list API is different from Hyprland's. The shell should detect this automatically, but if it's broken:

1. Check `NiriService` is loaded:
   ```bash
   qs log -c ii | grep NiriService
   ```

2. Check Niri is actually running:
   ```bash
   echo $NIRI_SOCKET
   ```

3. File a bug report with logs.

### Region selector doesn't highlight windows

This is expected. Niri doesn't expose layer shell info, so the region selector can't show you individual layer surfaces (bar, sidebars, etc.) as targets. It only sees windows.

You can still:
- Click a window to select it
- Drag to select a custom region
- Use content detection (OpenCV finds images/text regions)

---

## Performance

Niri is generally faster than Hyprland:

- Simpler window management (no floating)
- Better Wayland protocol compliance
- Less overhead in the compositor

The shell is optimized for Niri's scrolling workspace model. The overview doesn't try to render 10 static workspaces - it only shows what's visible in your current scroll position.

---

## Why Niri?

Because it doesn't crash. That's the main reason this fork exists.

If you want the original Hyprland version with more features and polish, check out [end-4's dots-hyprland](https://github.com/end-4/dots-hyprland).
