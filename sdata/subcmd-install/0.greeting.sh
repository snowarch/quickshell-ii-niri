# Greeting for ii-niri installer
# This script is meant to be sourced.

# shellcheck shell=bash

#####################################################################################
# System Detection
#####################################################################################
detect_system() {
  # Distro detection
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DETECTED_DISTRO="${PRETTY_NAME:-$NAME}"
    DETECTED_DISTRO_ID="${ID}"
  else
    DETECTED_DISTRO="Unknown Linux"
    DETECTED_DISTRO_ID="unknown"
  fi

  # Shell detection
  DETECTED_SHELL=$(basename "${SHELL:-unknown}")
  
  # DE/WM detection
  if [[ -n "$NIRI_SOCKET" ]]; then
    DETECTED_DE="Niri"
  elif [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    DETECTED_DE="Hyprland"
  elif [[ -n "$SWAYSOCK" ]]; then
    DETECTED_DE="Sway"
  elif [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
    DETECTED_DE="$XDG_CURRENT_DESKTOP"
  else
    DETECTED_DE="Not running"
  fi

  # Terminal detection
  DETECTED_TERM="${TERM_PROGRAM:-${TERM:-unknown}}"
  
  # Session type
  DETECTED_SESSION="${XDG_SESSION_TYPE:-unknown}"
  
  # Check for AUR helper
  if command -v yay &>/dev/null; then
    DETECTED_AUR="yay"
  elif command -v paru &>/dev/null; then
    DETECTED_AUR="paru"
  else
    DETECTED_AUR="none (will install yay)"
  fi
}

detect_system

#####################################################################################
# Banner
#####################################################################################
printf "${STY_CYAN}${STY_BOLD}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     ██╗██╗      ███╗   ██╗██╗██████╗ ██╗                     ║
║     ██║██║      ████╗  ██║██║██╔══██╗██║                     ║
║     ██║██║█████╗██╔██╗ ██║██║██████╔╝██║                     ║
║     ██║██║╚════╝██║╚██╗██║██║██╔══██╗██║                     ║
║     ██║██║      ██║ ╚████║██║██║  ██║██║                     ║
║     ╚═╝╚═╝      ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝╚═╝                     ║
║                                                              ║
║          illogical-impulse on Niri                           ║
║          Quickshell desktop environment                      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
printf "${STY_RST}\n"

#####################################################################################
# System Info Display
#####################################################################################
echo -e "${STY_BLUE}${STY_BOLD}┌─ System Detection${STY_RST}"
echo -e "${STY_BLUE}│${STY_RST}"
echo -e "${STY_BLUE}│${STY_RST}  ${STY_BOLD}Distro${STY_RST}      ${DETECTED_DISTRO}"
echo -e "${STY_BLUE}│${STY_RST}  ${STY_BOLD}Shell${STY_RST}       ${DETECTED_SHELL}"
echo -e "${STY_BLUE}│${STY_RST}  ${STY_BOLD}Session${STY_RST}     ${DETECTED_SESSION}"
echo -e "${STY_BLUE}│${STY_RST}  ${STY_BOLD}Compositor${STY_RST}  ${DETECTED_DE}"
echo -e "${STY_BLUE}│${STY_RST}  ${STY_BOLD}AUR Helper${STY_RST}  ${DETECTED_AUR}"
echo -e "${STY_BLUE}│${STY_RST}"
echo -e "${STY_BLUE}└──────────────────────────────${STY_RST}"
echo ""

# Arch check
if [[ "$DETECTED_DISTRO_ID" != "arch" && "$DETECTED_DISTRO_ID" != "endeavouros" && "$DETECTED_DISTRO_ID" != "manjaro" && "$DETECTED_DISTRO_ID" != "garuda" && "$DETECTED_DISTRO_ID" != "cachyos" ]]; then
  echo -e "${STY_RED}${STY_BOLD}⚠ Warning:${STY_RST} This installer is designed for Arch-based distros."
  echo -e "  Detected: ${DETECTED_DISTRO}"
  echo -e "  You can continue, but package installation may fail."
  echo ""
fi

#####################################################################################
# What will happen
#####################################################################################
echo -e "${STY_CYAN}${STY_BOLD}┌─ Installation Plan${STY_RST}"
echo -e "${STY_CYAN}│${STY_RST}"
echo -e "${STY_CYAN}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Install packages via pacman/AUR (Niri, Quickshell, Qt6, fonts...)"
echo -e "${STY_CYAN}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Configure user groups and systemd services"
echo -e "${STY_CYAN}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Setup GTK/Qt theming (Matugen, Kvantum, Darkly)"
echo -e "${STY_CYAN}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Configure ${DETECTED_SHELL} environment variables"
echo -e "${STY_CYAN}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Copy configs to ~/.config/ (with backups)"
echo -e "${STY_CYAN}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Set default wallpaper and generate initial theme"
echo -e "${STY_CYAN}│${STY_RST}"
echo -e "${STY_CYAN}└──────────────────────────────${STY_RST}"
echo ""

echo -e "${STY_YELLOW}${STY_BOLD}Note:${STY_RST} This may take a while depending on your internet speed."
echo -e "      Existing configs will be backed up to: ${STY_UNDERLINE}${BACKUP_DIR}${STY_RST}"
echo ""

if $ask; then
  printf "${STY_PURPLE}${STY_BOLD}Ready to install?${STY_RST} Press Enter to continue or Ctrl+C to abort... "
  read -r
  echo ""
fi
