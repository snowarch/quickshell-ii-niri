# Niri Compatibility Guide

This document outlines Niri-specific features and differences from Hyprland.

## Key Differences

### Keybindings
- **Hyprland**: Uses `GlobalShortcut` QML component
- **Niri**: Keybindings defined in `~/.config/niri/config.kdl`

All keybindings are pre-configured in `defaults/niri/config.kdl` and installed during setup.

### Workspace Model
- **Hyprland**: Traditional numbered workspaces (1-10)
- **Niri**: Scrolling workspace model (infinite horizontal scroll)

The shell adapts automatically via `CompositorService.isNiri`.

### Window Management
- **Hyprland**: Uses `HyprlandData.windowList` and layer shell info
- **Niri**: Uses `NiriService.windows` with different layout structure

Region selector automatically detects and uses the correct API.

## Niri-Specific Features

### IPC Integration
All shell functions work via Niri keybindings calling Quickshell IPC:

```kdl
bind "Mod+Space" { spawn "qs" "-c" "ii" "ipc" "call" "overview" "toggle"; }
bind "Mod+Shift+S" { spawn "qs" "-c" "ii" "ipc" "call" "region" "screenshot"; }
```

### Window Layout
Niri provides window layout info via `NiriService`:
- `tile_pos_in_workspace_view`: Window position in workspace
- `tile_size`: Window dimensions
- No floating/tiled distinction (all windows are tiled)

### Display Scaling
Niri uses per-output scaling:
```javascript
NiriService.displayScales[screen.name]
```

## Disabled Features in Niri

These features only work in Hyprland:
- `GlobalShortcut` components (use Niri keybindings instead)
- Layer shell queries (Niri doesn't expose layer info)
- Floating window detection
- Workspace-specific layer filtering

## Configuration

### Niri Config Location
`~/.config/niri/config.kdl`

### Default Keybindings
See `defaults/niri/config.kdl` for all pre-configured keybindings.

### Shell Config
Same as Hyprland: `~/.config/quickshell/ii/defaults/config.json`

## Troubleshooting

### Screenshots Not Working
Ensure `grim` is installed:
```bash
pacman -S grim
```

### Keybindings Not Working
1. Check Niri config: `~/.config/niri/config.kdl`
2. Reload Niri: `niri msg action reload-config`
3. Check IPC targets: See `docs/IPC.md`

### Region Selector Issues
- Niri doesn't support layer shell queries
- Window regions work via `NiriService.windows`
- Content detection uses OpenCV (same as Hyprland)

## Performance Notes

Niri is generally more efficient than Hyprland:
- Simpler window management model
- No floating window overhead
- Better Wayland protocol compliance

The shell is optimized for Niri's scrolling workspace model.
