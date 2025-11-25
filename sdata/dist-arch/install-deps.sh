# Install dependencies for ii-niri on Arch-based systems
# This script is meant to be sourced, not run directly.

# shellcheck shell=bash

#####################################################################################
# Verify we're on Arch
#####################################################################################
if ! command -v pacman >/dev/null 2>&1; then
  printf "${STY_RED}[$0]: pacman not found. This script is for Arch-based systems only.${STY_RST}\n"
  exit 1
fi

#####################################################################################
# System update
#####################################################################################
case $SKIP_SYSUPDATE in
  true) sleep 0;;
  *) v sudo pacman -Syu;;
esac

#####################################################################################
# Ensure AUR helper
#####################################################################################
if ! command -v yay >/dev/null 2>&1 && ! command -v paru >/dev/null 2>&1; then
  echo -e "${STY_YELLOW}[$0]: No AUR helper found.${STY_RST}"
  showfun install-yay
  v install-yay
fi

# Set AUR helper
if command -v yay >/dev/null 2>&1; then
  AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
  AUR_HELPER="paru"
fi

#####################################################################################
# Install packages from PKGBUILDs (read depends and install them)
#####################################################################################
echo -e "${STY_CYAN}[$0]: Installing packages from local PKGBUILDs...${STY_RST}"

# Function to install deps from a PKGBUILD
install_pkgbuild_deps() {
  local pkgbuild_dir="$1"
  local pkgbuild_file="${pkgbuild_dir}/PKGBUILD"
  
  if [[ ! -f "$pkgbuild_file" ]]; then
    echo -e "${STY_YELLOW}PKGBUILD not found: $pkgbuild_file${STY_RST}"
    return 1
  fi
  
  echo -e "${STY_BLUE}Reading dependencies from: $pkgbuild_file${STY_RST}"
  
  # Source PKGBUILD to get depends array
  local depends=()
  source "$pkgbuild_file"
  
  if [[ ${#depends[@]} -eq 0 ]]; then
    echo -e "${STY_YELLOW}No dependencies in $pkgbuild_file${STY_RST}"
    return 0
  fi
  
  echo -e "${STY_GREEN}Installing: ${depends[*]}${STY_RST}"
  
  local installflags="--needed"
  $ask || installflags="$installflags --noconfirm"
  
  # Install via pacman first (for official repos)
  sudo pacman -S $installflags "${depends[@]}" 2>/dev/null || {
    # Some packages may be AUR-only, try with AUR helper
    $AUR_HELPER -S $installflags "${depends[@]}"
  }
}

# Install from each PKGBUILD
for pkgdir in ./sdata/dist-arch/ii-niri-*/; do
  v install_pkgbuild_deps "$pkgdir"
done

#####################################################################################
# Install AUR packages
#####################################################################################
echo -e "${STY_CYAN}[$0]: Installing AUR packages...${STY_RST}"

AUR_PACKAGES=(
  # Quickshell (CRITICAL)
  quickshell-git
  google-breakpad
  qt6-avif-image-plugin
  
  # Fonts
  matugen-bin
  otf-space-grotesk
  ttf-jetbrains-mono-nerd
  ttf-material-symbols-variable-git
  ttf-readex-pro
  ttf-rubik-vf
  ttf-twemoji
  
  # Theming
  adw-gtk-theme-git
  capitaine-cursors
  
  # Widgets
  hyprpicker
  songrec
  
  # Audio visualization
  cava
  
  # Python env
  uv
)

installflags="--needed"
$ask || installflags="$installflags --noconfirm"

v $AUR_HELPER -S $installflags "${AUR_PACKAGES[@]}"

#####################################################################################
# Optional: Python environment setup
#####################################################################################
showfun install-python-packages
v install-python-packages

echo -e "${STY_GREEN}[$0]: Dependencies installed successfully.${STY_RST}"
