# Vesktop Theming

ii-niri includes automatic Discord/Vesktop theming that syncs with your wallpaper colors.

## Included Theme

### ii-system24
A TUI-style Discord theme based on [refact0r/system24](https://github.com/refact0r/system24) with Material You colors from your wallpaper.

Features:
- Oxanium font (ii-niri branding)
- ASCII-style decorations and loader
- Panel labels with uppercase styling
- Minimal, terminal-like aesthetic
- Blur support for Wayland compositors
- Full Material You color integration

## Setup

1. Install [Vesktop](https://github.com/Vencord/Vesktop) (or any Vencord-based client)

2. The theme is automatically installed to `~/.config/vesktop/themes/` during ii-niri setup

3. In Vesktop, go to Settings → Vencord → Themes and enable `ii-system24`

4. Colors will automatically update when you change your wallpaper!

## How It Works

When you change your wallpaper:

1. `switchwall.sh` runs matugen to generate Material You colors
2. `system24_palette.py` converts those colors to Discord CSS variables
3. The palette is saved to `~/.config/vesktop/themes/system24-palette.css`
4. Both themes import this palette, so they update automatically

## Manual Regeneration

If colors get out of sync, regenerate manually:

```fish
# Using the Python script directly
python3 ~/.config/quickshell/ii/scripts/colors/system24_palette.py

# Or trigger a full wallpaper refresh
~/.config/quickshell/ii/scripts/colors/switchwall.sh --noswitch
```

## Customization

### Changing Fonts

Edit the theme file in `~/.config/vesktop/themes/`:

```css
body {
    --font: 'Your Font';        /* Main font */
    --code-font: 'Mono Font';   /* Code blocks */
}
```

### Transparency/Blur

For transparent panels (requires compositor support):

```css
body {
    --transparency-tweaks: on;
    --panel-blur: on;
    --blur-amount: 12px;
    
    /* Make backgrounds semi-transparent */
    --bg-4: hsla(220, 15%, 10%, 0.7);
    --bg-3: hsla(220, 15%, 13%, 0.7);
}
```

### Background Image

```css
body {
    --background-image: on;
    --background-image-url: url('file:///path/to/image.png');
}
```

## Troubleshooting

### Colors not updating
- Check that `~/.config/vesktop/themes/system24-palette.css` exists
- Verify the theme is enabled in Vesktop settings
- Try restarting Vesktop after wallpaper change

### Theme not appearing
- Ensure the `.theme.css` files are in `~/.config/vesktop/themes/`
- Check Vesktop console for CSS errors (Ctrl+Shift+I)

### Wrong colors
- Run `switchwall.sh --noswitch` to regenerate without changing wallpaper
- Check `~/.local/state/quickshell/user/generated/colors.json` exists

## Credits

- [refact0r](https://github.com/refact0r) for system24 and midnight themes
- [Vencord](https://github.com/Vencord) for the Discord mod platform
