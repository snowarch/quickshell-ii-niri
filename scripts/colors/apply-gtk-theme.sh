#!/bin/bash
# Apply theme colors to GTK and KDE apps (for manual presets)
# Respects Advanced settings from config
# Usage: apply-gtk-theme.sh <bg> <fg> <primary> <on_primary> <surface> <surface_dim>

BG="${1:-#1e1e2e}"
FG="${2:-#cdd6f4}"
PRIMARY="${3:-#cba6f7}"
ON_PRIMARY="${4:-#1e1e2e}"
SURFACE="${5:-#1e1e2e}"
SURFACE_DIM="${6:-#11111b}"

GTK4_CSS="$HOME/.config/gtk-4.0/gtk.css"
GTK3_CSS="$HOME/.config/gtk-3.0/gtk.css"
KDEGLOBALS="$HOME/.config/kdeglobals"
SHELL_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/illogical-impulse/config.json"

# Read config options
enable_apps_shell="true"
enable_qt_apps="true"
if [[ -f "$SHELL_CONFIG_FILE" ]] && command -v jq &>/dev/null; then
    enable_apps_shell=$(jq -r '.appearance.wallpaperTheming.enableAppsAndShell // true' "$SHELL_CONFIG_FILE")
    enable_qt_apps=$(jq -r '.appearance.wallpaperTheming.enableQtApps // true' "$SHELL_CONFIG_FILE")
fi

# Exit if shell theming is disabled
if [[ "$enable_apps_shell" == "false" ]]; then
    exit 0
fi

# Helper
adjust_color() {
    local hex="${1#\#}"
    local amount="$2"
    local r=$((0x${hex:0:2} + amount))
    local g=$((0x${hex:2:2} + amount))
    local b=$((0x${hex:4:2} + amount))
    ((r < 0)) && r=0; ((r > 255)) && r=255
    ((g < 0)) && g=0; ((g > 255)) && g=255
    ((b < 0)) && b=0; ((b > 255)) && b=255
    printf "#%02x%02x%02x" $r $g $b
}

BG_ALT=$(adjust_color "$BG" 20)
BG_DARK=$(adjust_color "$BG" -20)
FG_INACTIVE=$(adjust_color "$FG" -60)

generate_gtk_css() {
    cat << EOF
@define-color accent_color ${PRIMARY};
@define-color accent_fg_color ${ON_PRIMARY};
@define-color accent_bg_color ${PRIMARY};
@define-color window_bg_color ${BG};
@define-color window_fg_color ${FG};
@define-color headerbar_bg_color ${SURFACE_DIM};
@define-color headerbar_fg_color ${FG};
@define-color view_bg_color ${SURFACE};
@define-color view_fg_color ${FG};
@define-color sidebar_bg_color ${BG};
@define-color sidebar_fg_color ${FG};
@define-color sidebar_backdrop_color ${BG};

placessidebar, placessidebar list { background-color: ${BG} !important; color: ${FG} !important; }
placessidebar row:selected { background-color: ${PRIMARY} !important; color: ${ON_PRIMARY} !important; }
.nautilus-window headerbar, .nautilus-window .view { background-color: ${BG} !important; color: ${FG} !important; }

/* Backdrop (unfocused) state */
placessidebar:backdrop, placessidebar list:backdrop { background-color: ${BG} !important; color: ${FG} !important; }
.nautilus-window:backdrop headerbar, .nautilus-window:backdrop .view { background-color: ${BG} !important; color: ${FG} !important; }
.nautilus-window:backdrop placessidebar { background-color: ${BG} !important; }
window:backdrop { background-color: ${BG} !important; }
EOF
}

generate_kdeglobals() {
    local icon_theme
    icon_theme=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")
    [[ -z "$icon_theme" ]] && icon_theme="Adwaita"
    
    cat << EOF
[ColorEffects:Disabled]
Color=${BG}
ColorAmount=0.5
ColorEffect=3
ContrastAmount=0
ContrastEffect=0
IntensityAmount=0
IntensityEffect=0

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=${BG_DARK}
ColorAmount=0.025
ColorEffect=0
ContrastAmount=0.1
ContrastEffect=0
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=${BG_ALT}
BackgroundNormal=${SURFACE}
DecorationFocus=${PRIMARY}
DecorationHover=${PRIMARY}
ForegroundActive=${FG}
ForegroundInactive=${FG_INACTIVE}
ForegroundLink=${PRIMARY}
ForegroundNegative=#ff6b6b
ForegroundNeutral=#ffa94d
ForegroundNormal=${FG}
ForegroundPositive=#69db7c
ForegroundVisited=${PRIMARY}

[Colors:Selection]
BackgroundAlternate=${PRIMARY}
BackgroundNormal=${PRIMARY}
DecorationFocus=${PRIMARY}
DecorationHover=${PRIMARY}
ForegroundActive=${ON_PRIMARY}
ForegroundInactive=${ON_PRIMARY}
ForegroundLink=${ON_PRIMARY}
ForegroundNegative=${ON_PRIMARY}
ForegroundNeutral=${ON_PRIMARY}
ForegroundNormal=${ON_PRIMARY}
ForegroundPositive=${ON_PRIMARY}
ForegroundVisited=${ON_PRIMARY}

[Colors:Tooltip]
BackgroundAlternate=${BG_ALT}
BackgroundNormal=${BG}
DecorationFocus=${PRIMARY}
DecorationHover=${PRIMARY}
ForegroundActive=${FG}
ForegroundInactive=${FG_INACTIVE}
ForegroundLink=${PRIMARY}
ForegroundNegative=#ff6b6b
ForegroundNeutral=#ffa94d
ForegroundNormal=${FG}
ForegroundPositive=#69db7c
ForegroundVisited=${PRIMARY}

[Colors:View]
BackgroundAlternate=${BG}
BackgroundNormal=${BG}
DecorationFocus=${PRIMARY}
DecorationHover=${PRIMARY}
ForegroundActive=${FG}
ForegroundInactive=${FG_INACTIVE}
ForegroundLink=${PRIMARY}
ForegroundNegative=#ff6b6b
ForegroundNeutral=#ffa94d
ForegroundNormal=${FG}
ForegroundPositive=#69db7c
ForegroundVisited=${PRIMARY}

[Colors:Window]
BackgroundAlternate=${BG}
BackgroundNormal=${BG}
DecorationFocus=${PRIMARY}
DecorationHover=${PRIMARY}
ForegroundActive=${FG}
ForegroundInactive=${FG_INACTIVE}
ForegroundLink=${PRIMARY}
ForegroundNegative=#ff6b6b
ForegroundNeutral=#ffa94d
ForegroundNormal=${FG}
ForegroundPositive=#69db7c
ForegroundVisited=${PRIMARY}

[Colors:Complementary]
BackgroundAlternate=${BG_DARK}
BackgroundNormal=${BG}
DecorationFocus=${PRIMARY}
DecorationHover=${PRIMARY}
ForegroundActive=${FG}
ForegroundInactive=${FG_INACTIVE}
ForegroundLink=${PRIMARY}
ForegroundNegative=#ff6b6b
ForegroundNeutral=#ffa94d
ForegroundNormal=${FG}
ForegroundPositive=#69db7c
ForegroundVisited=${PRIMARY}

[Colors:Header]
BackgroundAlternate=${BG}
BackgroundNormal=${BG}
DecorationFocus=${PRIMARY}
DecorationHover=${PRIMARY}
ForegroundActive=${FG}
ForegroundInactive=${FG_INACTIVE}
ForegroundLink=${PRIMARY}
ForegroundNegative=#ff6b6b
ForegroundNeutral=#ffa94d
ForegroundNormal=${FG}
ForegroundPositive=#69db7c
ForegroundVisited=${PRIMARY}

[General]
ColorScheme=IINiriPreset

[Icons]
Theme=${icon_theme}

[KDE]
widgetStyle=Darkly

[WM]
activeBackground=${BG}
activeBlend=${FG}
activeForeground=${FG}
inactiveBackground=${BG}
inactiveBlend=${FG_INACTIVE}
inactiveForeground=${FG_INACTIVE}
EOF
}

# Apply GTK
mkdir -p "$(dirname "$GTK4_CSS")" "$(dirname "$GTK3_CSS")"
[[ -L "$GTK4_CSS" ]] && rm "$GTK4_CSS"
[[ -L "$GTK3_CSS" ]] && rm "$GTK3_CSS"
generate_gtk_css > "$GTK4_CSS"
generate_gtk_css > "$GTK3_CSS"

# Apply KDE if enabled
if [[ "$enable_qt_apps" != "false" ]]; then
    generate_kdeglobals > "$KDEGLOBALS"
fi

# Restart Nautilus
nautilus -q 2>/dev/null &
