# Vesktop Theming

ii-niri includes automatic Discord/Vesktop theming that syncs with your wallpaper colors.

## Included Theme

### ii-system24
A Material Design Discord theme based on [refact0r/system24](https://github.com/refact0r/system24) with Material You colors from your wallpaper.

Features:
- Oxanium font (ii-niri branding)
- Material Design styling (rounded corners, proper spacing)
- Compact server icons and scrollbars
- Full Material You color integration
- Auto-sync with wallpaper changes
- Auto-sync with theme preset changes

## Setup

1. Install [Vesktop](https://github.com/Vencord/Vesktop) (or any Vencord-based client)

2. The theme is automatically installed to `~/.config/vesktop/themes/` during ii-niri setup

3. In Vesktop, go to Settings → Vencord → Themes and enable `system24`

4. Colors will automatically update when you change your wallpaper or theme preset!

## How It Works

### Wallpaper Changes (Auto mode)
When you change your wallpaper:
1. `switchwall.sh` runs matugen to generate Material You colors
2. `system24_palette.py` generates the complete theme with embedded palette
3. `reload-vesktop.fish` sends Ctrl+R to Vesktop to reload

### Theme Preset Changes
When you change theme preset in Settings:
1. `apply-gtk-theme.sh` applies GTK/KDE colors
2. It also calls `system24_palette.py` to regenerate Vesktop theme
3. `reload-vesktop.fish` reloads Vesktop automatically

### Color Mapping

| system24 Variable | Material You Source |
|-------------------|---------------------|
| `--accent-*` | `primary` color ladder |
| `--accent-new` | `primary` (for NEW badge) |
| `--bg-*` | `surface_container_*` variants |
| `--text-*` | `on_surface` / `on_surface_variant` |
| `--red-*` | `error` color ladder |
| `--green-*` | `tertiary` color ladder |
| `--blue-*` | `secondary` color ladder |

## Manual Regeneration

If colors get out of sync, regenerate manually:

```fish
# Regenerate theme
python3 ~/.config/quickshell/ii/scripts/colors/system24_palette.py

# Reload Vesktop
fish ~/.config/quickshell/ii/scripts/colors/reload-vesktop.fish

# Or trigger a full wallpaper refresh
~/.config/quickshell/ii/scripts/colors/switchwall.sh --noswitch
```

## Customization

### Changing Fonts

Edit `scripts/colors/system24_palette.py` and change the font variables:

```css
body {
    --font: 'Your Font';        /* Main font */
    --code-font: 'Mono Font';   /* Code blocks */
}
```

Then regenerate the theme.

## Troubleshooting

### Colors not updating
- Check that `~/.config/vesktop/themes/system24.theme.css` exists
- Verify the theme is enabled in Vesktop settings
- Try Ctrl+R in Vesktop to force reload

### Theme not appearing
- Ensure the `.theme.css` file is in `~/.config/vesktop/themes/`
- Check Vesktop console for CSS errors (Ctrl+Shift+I)

### Wrong colors
- Run `python3 ~/.config/quickshell/ii/scripts/colors/system24_palette.py` to regenerate
- Check `~/.local/state/quickshell/user/generated/colors.json` exists

### Hot-reload not working
- The theme palette is embedded in the main file, so Ctrl+R should work
- If Vesktop window is not focused, the reload script may not work
- Try manually pressing Ctrl+R in Vesktop

## Credits

- [refact0r](https://github.com/refact0r) for system24 theme base
- [Vencord](https://github.com/Vencord) for the Discord mod platform
