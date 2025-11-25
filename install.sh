#!/usr/bin/env bash
set -euo pipefail

bold="" reset="" green="" yellow="" red=""
if command -v tput >/dev/null 2>&1; then
  bold="$(tput bold || true)"
  reset="$(tput sgr0 || true)"
  green="$(tput setaf 2 || true)"
  yellow="$(tput setaf 3 || true)"
  red="$(tput setaf 1 || true)"
fi

log() {
  local level="$1"; shift
  case "$level" in
    INFO) printf '%s[%s]%s %s\n'  "$bold" "INFO" "$reset" "$*" ;;
    WARN) printf '%s[%s]%s %s%s%s\n' "$bold" "WARN" "$reset" "$yellow" "$*" "$reset" ;;
    ERR)  printf '%s[%s]%s %s%s%s\n' "$bold" "ERR"  "$reset" "$red" "$*" "$reset" ;;
    *)    printf '[%s] %s\n' "$level" "$*" ;;
  esac
}

ask_yes_no() {
  local prompt="$1" default="$2" reply
  local suffix="[y/N]"
  case "$default" in
    y|Y) suffix="[Y/n]" ;;
    n|N) suffix="[y/N]" ;;
  esac
  while true; do
    printf '%s %s ' "$prompt" "$suffix"
    if [ -t 0 ]; then
      # Normal interactive shell: read from stdin.
      read -r reply || reply=""
    elif [ -r /dev/tty ]; then
      # When run via a pipe (e.g. curl ... | bash), stdin is not a TTY.
      # Read answers from the controlling terminal instead.
      read -r reply < /dev/tty || reply=""
    else
      # Non-interactive environment with no TTY: fall back to default.
      echo
      reply="$default"
    fi
    reply="${reply:-$default}"
    case "$reply" in
      y|Y) return 0 ;;
      n|N) return 1 ;;
    esac
    echo "Please answer y or n."
  done
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then
    return 0
  fi

  log INFO 'Installing "yay" (AUR helper) to handle repo + AUR packages.'
  sudo pacman -S --needed base-devel git

  local tmpdir
  tmpdir="$(mktemp -d)"
  (
    cd "$tmpdir"
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
  )
  rm -rf "$tmpdir"
}

install_repo_pkgs() {
  local pkgs=("$@")
  if [ ${#pkgs[@]} -eq 0 ]; then
    return 0
  fi
  sudo pacman -S --needed "${pkgs[@]}"
}

install_aur_pkgs() {
  local pkgs=("$@")
  if [ ${#pkgs[@]} -eq 0 ]; then
    return 0
  fi
  ensure_yay
  yay -S --needed "${pkgs[@]}"
}

log INFO "Installing illogical-impulse (ii) on Niri (Arch-based systems)."

if ! require_cmd pacman; then
  log ERR "This installer currently supports only Arch-based distros (pacman)."
  exit 1
fi

if ! require_cmd sudo; then
  log ERR "This script needs sudo for pacman. Install sudo first."
  exit 1
fi

CORE_PKGS=(
  niri
  quickshell
  wl-clipboard
  cliphist
  libnotify
  pipewire
  pipewire-pulse
  pipewire-alsa
  pipewire-jack
  git
)

RECOMMENDED_PKGS=(
  grim
  slurp
  wf-recorder
  imagemagick
  swappy
  tesseract
  jq
  curl
  xdg-utils
  matugen
  mpvpaper
  ffmpeg
  hyprpicker
  networkmanager
  nm-connection-editor
  easyeffects
  warp-cli
  songrec
  upower
)

TOOLKIT_REPO_PKGS=(
  ydotool
  wtype
  python-evdev
)

TOOLKIT_AUR_PKGS=(
  illogical-impulse-python
)

AI_REPO_PKGS=(
  libsecret
  gnome-keyring
)

AI_AUR_PKGS=(
  ollama
)

THEME_REPO_PKGS=(
  capitaine-cursors
)

THEME_AUR_PKGS=(
  whitesur-icon-theme-git
  whitesur-gtk-theme-git
)

log INFO "Installing core packages with pacman (requires sudo)."
sudo pacman -S --needed "${CORE_PKGS[@]}"

if ask_yes_no "Install recommended extras (screenshots, recording, theming helpers, WARP, etc.)?" "y"; then
  log INFO "Installing recommended extras."
  sudo pacman -S --needed "${RECOMMENDED_PKGS[@]}"
else
  log INFO "Skipping recommended extras."
fi

if ask_yes_no "Install input toolkit and Super key dependencies (ydotool, wtype, python-evdev, illogical-impulse-python)?" "y"; then
  log INFO "Installing toolkit packages."
  install_repo_pkgs "${TOOLKIT_REPO_PKGS[@]}"
  install_aur_pkgs "${TOOLKIT_AUR_PKGS[@]}"
else
  log INFO "Skipping toolkit packages. Some OSK / superpaste features may be limited."
fi

if ask_yes_no "Install AI and keyring helpers (libsecret, gnome-keyring, optional Ollama)?" "n"; then
  log INFO "Installing AI/keyring helpers."
  install_repo_pkgs "${AI_REPO_PKGS[@]}"
  install_aur_pkgs "${AI_AUR_PKGS[@]}"
else
  log INFO "Skipping AI/keyring helpers. Gemini/Ollama helpers will remain idle unless you configure them manually."
fi

if ask_yes_no "Install icon/cursor themes (WhiteSur GTK/icons via AUR + Capitaine cursors)?" "n"; then
  log INFO "Installing icon and cursor themes."
  install_repo_pkgs "${THEME_REPO_PKGS[@]}"
  install_aur_pkgs "${THEME_AUR_PKGS[@]}"
else
  log INFO "Skipping icon/cursor themes. Your existing GTK/icon setup will be used."
fi

CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"
QS_DIR="$CONFIG_ROOT/quickshell"
II_DIR="$QS_DIR/ii"
REPO_URL="${REPO_URL:-https://github.com/snowarch/quickshell-ii-niri.git}"

mkdir -p "$QS_DIR"

if [ -d "$II_DIR/.git" ]; then
  log INFO "Found existing ii git repo at $II_DIR."
  if ask_yes_no "Update it from $REPO_URL?" "y"; then
    git -C "$II_DIR" pull --ff-only
  else
    log INFO "Leaving existing ii config as-is."
  fi
else
  if [ -d "$II_DIR" ] && [ ! -d "$II_DIR/.git" ]; then
    log WARN "$II_DIR exists but is not a git clone. Leaving it untouched."
  else
    log INFO "Cloning ii config into $II_DIR."
    git clone "$REPO_URL" "$II_DIR"
  fi
fi

WORKSPACE_DIR="$HOME/quickshell-workspace/ii"
if ask_yes_no "Also keep a workspace clone at $WORKSPACE_DIR?" "n"; then
  mkdir -p "$(dirname "$WORKSPACE_DIR")"
  if [ -d "$WORKSPACE_DIR/.git" ]; then
    log INFO "Workspace clone already exists at $WORKSPACE_DIR."
  else
    log INFO "Cloning workspace repo into $WORKSPACE_DIR."
    git clone "$REPO_URL" "$WORKSPACE_DIR"
  fi
fi

NIRI_CONFIG="$CONFIG_ROOT/niri/config.kdl"
if [ -f "$NIRI_CONFIG" ]; then
  if grep -q 'spawn-at-startup "qs" "-c" "ii"' "$NIRI_CONFIG"; then
    log INFO "Niri already starts ii at login."
  else
    if ask_yes_no "Add 'spawn-at-startup \"qs\" \"-c\" \"ii\"' to $NIRI_CONFIG?" "y"; then
      {
        echo
        echo "// ii shell on Niri"
        echo "spawn-at-startup \"qs\" \"-c\" \"ii\""
      } >> "$NIRI_CONFIG"
      log INFO "Added ii spawn line to $NIRI_CONFIG."
    else
      log INFO "Skipped editing $NIRI_CONFIG. Add the spawn line manually if needed."
    fi
  fi
else
  log WARN "Could not find $NIRI_CONFIG. Make sure Niri starts ii with:"
  echo '  spawn-at-startup "qs" "-c" "ii"'
fi

if ask_yes_no "Install and enable the Super-tap daemon for ii overview on Niri?" "y"; then
  log INFO "Installing Super-tap daemon files."
  CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"
  SYSTEMD_USER_DIR="$CONFIG_ROOT/systemd/user"

  mkdir -p "$HOME/.local/bin" "$SYSTEMD_USER_DIR"

  install -Dm755 "$II_DIR/scripts/daemon/ii_super_overview_daemon.py" \
    "$HOME/.local/bin/ii_super_overview_daemon.py"

  install -Dm644 "$II_DIR/scripts/systemd/ii-super-overview.service" \
    "$SYSTEMD_USER_DIR/ii-super-overview.service"

  if command -v systemctl >/dev/null 2>&1; then
    if systemctl --user daemon-reload 2>/dev/null; then
      if ! systemctl --user enable --now ii-super-overview.service 2>/dev/null; then
        log WARN "Could not enable ii-super-overview.service automatically. After logging into a graphical session, run:"
        echo "  systemctl --user enable --now ii-super-overview.service"
      else
        log INFO "Super-tap daemon enabled as a user service (ii-super-overview.service)."
      fi
    else
      log WARN "systemctl --user is not available in this shell. Once in a graphical session, enable the service with:"
      echo "  systemctl --user enable --now ii-super-overview.service"
    fi
  else
    log WARN "systemctl not found; install systemd user session support to manage ii-super-overview.service."
  fi
else
  log INFO "Skipping Super-tap daemon installation. You can still add it later from scripts/daemon and scripts/systemd."
fi

log INFO "Done. You can now restart Niri or reload its config:"
echo "  niri msg action reload-config"
echo "  qs -c ii"
