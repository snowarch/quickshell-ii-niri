# Greeting for ii-niri installer
# This script is meant to be sourced.

# shellcheck shell=bash

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

echo -e "${STY_CYAN}This installer will:${STY_RST}"
echo "  1. Install required packages (Niri, Quickshell, Qt6, fonts, etc.)"
echo "  2. Setup user groups and services (ydotool, etc.)"
echo "  3. Copy configuration files to ~/.config/"
echo ""
echo -e "${STY_YELLOW}Your existing configs will be backed up to: ${BACKUP_DIR}${STY_RST}"
echo ""

if $ask; then
  printf "${STY_PURPLE}Press Enter to continue or Ctrl+C to abort...${STY_RST}"
  read -r
fi
