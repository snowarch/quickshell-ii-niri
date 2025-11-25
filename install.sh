#!/usr/bin/env bash
# =============================================================================
# illogical-impulse (ii) on Niri - Installer
# =============================================================================
# One-shot installer for Arch-based systems that replicates the exact
# configuration from the original end-4 dots-hyprland, adapted for Niri.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/snowarch/quickshell-ii-niri/main/install.sh | bash
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
REPO_URL="${REPO_URL:-https://github.com/snowarch/quickshell-ii-niri.git}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
BOLD='\e[1m'
RST='\e[0m'

# -----------------------------------------------------------------------------
# LOGGING
# -----------------------------------------------------------------------------
log() {
    case "$1" in
        INFO)  shift; printf "${GREEN}✓${RST} %s\n" "$*" ;;
        WARN)  shift; printf "${YELLOW}⚠${RST} %s\n" "$*" ;;
        ERR)   shift; printf "${RED}✗${RST} %s\n" "$*" ;;
        STEP)  shift; printf "\n${BOLD}${CYAN}▶ %s${RST}\n" "$*" ;;
        *)     printf "[%s] %s\n" "$1" "${*:2}" ;;
    esac
}

confirm() {
    local prompt="$1"
    printf "%s [Y/n] " "$prompt"
    read -r reply </dev/tty || reply="y"
    [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
}

# -----------------------------------------------------------------------------
# PACKAGE INSTALLATION
# -----------------------------------------------------------------------------
detect_aur_helper() {
    if command -v yay &>/dev/null; then
        echo "yay"
    elif command -v paru &>/dev/null; then
        echo "paru"
    else
        echo ""
    fi
}

install_yay() {
    log STEP "Installing yay (AUR helper)"
    sudo pacman -S --needed --noconfirm base-devel git
    local tmpdir
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
}

install_packages() {
    local helper
    helper=$(detect_aur_helper)
    
    if [[ -z "$helper" ]]; then
        install_yay
        helper="yay"
    fi
    
    log STEP "Installing packages with $helper"
    
    # All packages in one shot - extracted from end-4 PKGBUILDs
    local pkgs=(
        # Niri compositor
        niri
        
        # Quickshell and Qt6 (from illogical-impulse-quickshell-git PKGBUILD)
        qt6-declarative qt6-base qt6-svg qt6-wayland qt6-5compat
        qt6-imageformats qt6-multimedia qt6-positioning qt6-quicktimeline
        qt6-sensors qt6-tools qt6-translations qt6-virtualkeyboard
        jemalloc libpipewire libxcb wayland libdrm mesa
        kirigami kdialog syntax-highlighting
        
        # XDG Portals (from illogical-impulse-portal, adapted for Niri)
        xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-gnome
        
        # Basic utils (from illogical-impulse-basic)
        bc coreutils cliphist cmake curl wget ripgrep jq xdg-user-dirs rsync git
        wl-clipboard libnotify
        
        # Audio (from illogical-impulse-audio)
        pipewire pipewire-pulse pipewire-alsa wireplumber playerctl
        libdbusmenu-gtk3 pavucontrol
        
        # Toolkit (from illogical-impulse-toolkit)
        upower wtype ydotool
        
        # Backlight (from illogical-impulse-backlight)
        brightnessctl ddcutil geoclue
        
        # Screencapture (adapted - grim instead of hyprshot)
        grim slurp swappy tesseract tesseract-data-eng wf-recorder imagemagick
        
        # Widgets (adapted - removed hyprlock/hypridle)
        fuzzel glib2
        
        # Python (from illogical-impulse-python)
        python gtk4 libadwaita libsoup3 gobject-introspection
        
        # KDE integration (adapted for Niri)
        gnome-keyring networkmanager dolphin
        breeze qt6ct kde-gtk-config
        
        # Fonts and themes base
        fontconfig
        
        # Polkit
        polkit mate-polkit
    )
    
    # AUR packages
    local aur_pkgs=(
        # Quickshell
        quickshell-git google-breakpad qt6-avif-image-plugin
        
        # Basic
        go-yq gum
        
        # Audio
        cava
        
        # Widgets
        hyprpicker songrec translate-shell
        
        # Python
        uv
        
        # Fonts (from illogical-impulse-fonts-themes)
        matugen-bin
        otf-space-grotesk
        ttf-jetbrains-mono-nerd
        ttf-material-symbols-variable-git
        ttf-readex-pro
        ttf-rubik-vf
        ttf-twemoji
        
        # Themes
        adw-gtk-theme-git
        whitesur-icon-theme-git
        capitaine-cursors
        breeze-plus
        darkly-bin
    )
    
    log INFO "Installing official packages..."
    sudo pacman -S --needed --noconfirm "${pkgs[@]}" 2>/dev/null || {
        log WARN "Some packages may have failed, continuing..."
    }
    
    log INFO "Installing AUR packages..."
    $helper -S --needed --noconfirm "${aur_pkgs[@]}" 2>/dev/null || {
        log WARN "Some AUR packages may have failed, continuing..."
    }
}

# -----------------------------------------------------------------------------
# CONFIGURATION SETUP
# -----------------------------------------------------------------------------
setup_ii_config() {
    log STEP "Setting up ii configuration"
    
    local ii_dir="$XDG_CONFIG_HOME/quickshell/ii"
    
    if [[ -d "$ii_dir/.git" ]]; then
        log INFO "Updating existing ii config..."
        git -C "$ii_dir" fetch origin
        git -C "$ii_dir" reset --hard origin/main
    else
        log INFO "Cloning ii config..."
        rm -rf "$ii_dir"
        mkdir -p "$(dirname "$ii_dir")"
        git clone --depth 1 "$REPO_URL" "$ii_dir"
    fi
    
    # Create state directories
    mkdir -p "$XDG_STATE_HOME/quickshell/user/generated/wallpaper"
    mkdir -p "$XDG_CACHE_HOME/quickshell"
    
    # Copy default config.json if not exists
    local config_file="$XDG_CONFIG_HOME/illogical-impulse/config.json"
    if [[ ! -f "$config_file" ]]; then
        mkdir -p "$(dirname "$config_file")"
        cp "$ii_dir/defaults/config.json" "$config_file"
        log INFO "Created default config.json"
    fi
    
    log INFO "ii config ready at $ii_dir"
}

setup_kde_theming() {
    log STEP "Setting up KDE/Dolphin theming"
    
    local ii_dir="$XDG_CONFIG_HOME/quickshell/ii"
    
    # Copy kdeglobals (critical for Dolphin theming)
    if [[ -f "$ii_dir/defaults/kde/kdeglobals" ]]; then
        cp "$ii_dir/defaults/kde/kdeglobals" "$XDG_CONFIG_HOME/kdeglobals"
        log INFO "Installed kdeglobals (KDE color scheme)"
    fi
    
    # Copy dolphinrc
    if [[ -f "$ii_dir/defaults/kde/dolphinrc" ]]; then
        cp "$ii_dir/defaults/kde/dolphinrc" "$XDG_CONFIG_HOME/dolphinrc"
        log INFO "Installed dolphinrc"
    fi
    
    # Set KDE widget style
    if command -v kwriteconfig6 &>/dev/null; then
        kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Darkly
        log INFO "Set widget style to Darkly"
    fi
}

setup_gtk_theming() {
    log STEP "Setting up GTK theming"
    
    local ii_dir="$XDG_CONFIG_HOME/quickshell/ii"
    
    # Copy GTK settings
    mkdir -p "$XDG_CONFIG_HOME/gtk-3.0" "$XDG_CONFIG_HOME/gtk-4.0"
    
    if [[ -f "$ii_dir/defaults/gtk-3.0/settings.ini" ]]; then
        cp "$ii_dir/defaults/gtk-3.0/settings.ini" "$XDG_CONFIG_HOME/gtk-3.0/"
    fi
    
    if [[ -f "$ii_dir/defaults/gtk-4.0/settings.ini" ]]; then
        cp "$ii_dir/defaults/gtk-4.0/settings.ini" "$XDG_CONFIG_HOME/gtk-4.0/"
    fi
    
    # Set cursor theme
    mkdir -p "$HOME/.icons/default"
    cat > "$HOME/.icons/default/index.theme" << 'EOF'
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=capitaine-cursors-light
EOF
    
    # Apply gsettings
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors-light' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface font-name 'Rubik 11' 2>/dev/null || true
        log INFO "Applied gsettings"
    fi
}

setup_matugen() {
    log STEP "Setting up Matugen"
    
    local ii_dir="$XDG_CONFIG_HOME/quickshell/ii"
    local matugen_dir="$XDG_CONFIG_HOME/matugen"
    
    # Copy entire matugen config from defaults
    if [[ -d "$ii_dir/defaults/matugen" ]]; then
        rm -rf "$matugen_dir"
        cp -r "$ii_dir/defaults/matugen" "$matugen_dir"
        
        # Fix paths in config.toml for user's home
        sed -i "s|~|$HOME|g" "$matugen_dir/config.toml"
        
        log INFO "Installed matugen config and templates"
    fi
    
    # Create output directories
    mkdir -p "$XDG_STATE_HOME/quickshell/user/generated/wallpaper"
}

setup_fuzzel() {
    log STEP "Setting up Fuzzel"
    
    local ii_dir="$XDG_CONFIG_HOME/quickshell/ii"
    local fuzzel_dir="$XDG_CONFIG_HOME/fuzzel"
    
    mkdir -p "$fuzzel_dir"
    
    if [[ -f "$ii_dir/defaults/fuzzel/fuzzel.ini" ]]; then
        cp "$ii_dir/defaults/fuzzel/fuzzel.ini" "$fuzzel_dir/"
        log INFO "Installed fuzzel config"
    fi
}

setup_niri_config() {
    log STEP "Setting up Niri config"
    
    local ii_dir="$XDG_CONFIG_HOME/quickshell/ii"
    local niri_dir="$XDG_CONFIG_HOME/niri"
    local config_file="$niri_dir/config.kdl"
    
    mkdir -p "$niri_dir"
    
    if [[ -f "$config_file" ]]; then
        # Config exists - check if it has ii binds
        if grep -q "qs.*-c.*ii" "$config_file"; then
            log INFO "Niri config already has ii integration"
        else
            log WARN "Existing Niri config found without ii binds"
            if confirm "Add ii keybinds to existing config?"; then
                # Append ii binds before last closing brace
                cat >> "$config_file" << 'EOF'

// illogical-impulse (ii) integration - added by installer
spawn-at-startup "qs" "-c" "ii"

binds {
    // ii Window Switcher
    Alt+Tab { spawn "qs" "-c" "ii" "ipc" "call" "altSwitcher" "next"; }
    Alt+Shift+Tab { spawn "qs" "-c" "ii" "ipc" "call" "altSwitcher" "previous"; }
    
    // ii Overlay
    Super+G { spawn "qs" "-c" "ii" "ipc" "call" "overlay" "toggle"; }
    
    // ii Clipboard
    Mod+V { spawn "qs" "-c" "ii" "ipc" "call" "clipboard" "toggle"; }
    
    // ii Lock screen
    Mod+Alt+L allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "lock" "activate"; }
    
    // ii Region tools
    Mod+Shift+S { spawn "qs" "-c" "ii" "ipc" "call" "region" "screenshot"; }
    Mod+Shift+X { spawn "qs" "-c" "ii" "ipc" "call" "region" "ocr"; }
    
    // ii Wallpaper selector
    Ctrl+Alt+T { spawn "qs" "-c" "ii" "ipc" "call" "wallpaperSelector" "toggle"; }
}
EOF
                log INFO "Added ii binds to existing config"
            fi
        fi
    else
        # No config - copy base config
        if [[ -f "$ii_dir/defaults/niri/config.kdl" ]]; then
            cp "$ii_dir/defaults/niri/config.kdl" "$config_file"
            log INFO "Installed base Niri config with ii integration"
        else
            log WARN "No base config found, you'll need to configure Niri manually"
        fi
    fi
}

setup_services() {
    log STEP "Setting up system services"
    
    # User groups
    if ! groups | grep -q input; then
        sudo usermod -aG input "$(whoami)" 2>/dev/null || true
        log INFO "Added user to input group (re-login required)"
    fi
    
    if ! groups | grep -q video; then
        sudo usermod -aG video "$(whoami)" 2>/dev/null || true
        log INFO "Added user to video group"
    fi
    
    # ydotool service
    if [[ -f /usr/lib/systemd/system/ydotool.service ]]; then
        if [[ ! -e /usr/lib/systemd/user/ydotool.service ]]; then
            sudo ln -sf /usr/lib/systemd/system/ydotool.service /usr/lib/systemd/user/ydotool.service 2>/dev/null || true
        fi
        systemctl --user daemon-reload 2>/dev/null || true
        systemctl --user enable --now ydotool 2>/dev/null || true
        log INFO "Enabled ydotool service"
    fi
}

setup_python_venv() {
    log STEP "Setting up Python environment"
    
    local venv_dir="$XDG_STATE_HOME/quickshell/.venv"
    
    if ! command -v uv &>/dev/null; then
        log WARN "uv not installed, skipping Python venv"
        return
    fi
    
    if [[ ! -d "$venv_dir/bin" ]]; then
        mkdir -p "$venv_dir"
        uv venv --prompt .venv "$venv_dir" -p 3.12 2>/dev/null || uv venv --prompt .venv "$venv_dir" || {
            log WARN "Could not create Python venv"
            return
        }
    fi
    
    # Install packages
    source "$venv_dir/bin/activate"
    uv pip install pillow opencv-contrib-python material-color-utilities numpy psutil 2>/dev/null || true
    deactivate
    
    log INFO "Python venv ready at $venv_dir"
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
show_banner() {
    printf "\n${BOLD}${CYAN}"
    printf "╔══════════════════════════════════════════╗\n"
    printf "║     illogical-impulse (ii) on Niri       ║\n"
    printf "║          One-shot Installer              ║\n"
    printf "╚══════════════════════════════════════════╝${RST}\n\n"
}

show_completion() {
    printf "\n${BOLD}${GREEN}"
    printf "╔══════════════════════════════════════════╗\n"
    printf "║         Installation Complete!           ║\n"
    printf "╚══════════════════════════════════════════╝${RST}\n\n"
    
    printf "${CYAN}Next steps:${RST}\n"
    printf "  1. Log out and log back in (for group changes)\n"
    printf "  2. Select 'Niri' at your display manager\n"
    printf "  3. ii should start automatically\n\n"
    
    printf "${CYAN}Useful commands:${RST}\n"
    printf "  niri msg action reload-config  # Reload Niri config\n"
    printf "  qs -c ii                        # Start ii manually\n\n"
    
    printf "${CYAN}Issues:${RST} https://github.com/snowarch/quickshell-ii-niri\n\n"
}

main() {
    show_banner
    
    # Check we're on Arch
    if [[ ! -f /etc/arch-release ]] && ! command -v pacman &>/dev/null; then
        log ERR "This installer is for Arch-based systems only"
        exit 1
    fi
    
    log STEP "Starting installation"
    
    # Install all packages
    install_packages
    
    # Setup configurations
    setup_ii_config
    setup_kde_theming
    setup_gtk_theming
    setup_matugen
    setup_fuzzel
    setup_niri_config
    setup_services
    setup_python_venv
    
    show_completion
}

main "$@"
