# Options parser for ii-niri installer
# This script is meant to be sourced.

# shellcheck shell=bash

showhelp_install(){
printf "[$0]: Install illogical-impulse on Niri.

Syntax:
  $0 install [OPTIONS]...

Options:
  -y, --yes           Skip confirmation prompts (auto-yes)
  --firstrun          Force first-run behavior (backup existing configs)
  --skip-deps         Skip dependency installation
  --skip-setups       Skip service/permission setup
  --skip-files        Skip config file installation
  --skip-quickshell   Skip Quickshell config sync
  --skip-niri         Skip Niri config installation
  --skip-backup       Skip backup of existing configs
  -h, --help          Show this help

Examples:
  $0 install              Interactive installation
  $0 install -y           Non-interactive installation
  $0 install --skip-deps  Skip dependencies (if already installed)
"
}

# Default values
ask=true
INSTALL_FIRSTRUN=""
SKIP_ALLDEPS=false
SKIP_ALLSETUPS=false
SKIP_ALLFILES=false
SKIP_QUICKSHELL=false
SKIP_NIRI=false
SKIP_BACKUP=false
SKIP_SYSUPDATE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -y|--yes)
      ask=false
      shift
      ;;
    --firstrun)
      INSTALL_FIRSTRUN=true
      shift
      ;;
    --skip-deps)
      SKIP_ALLDEPS=true
      shift
      ;;
    --skip-setups)
      SKIP_ALLSETUPS=true
      shift
      ;;
    --skip-files)
      SKIP_ALLFILES=true
      shift
      ;;
    --skip-quickshell)
      SKIP_QUICKSHELL=true
      shift
      ;;
    --skip-niri)
      SKIP_NIRI=true
      shift
      ;;
    --skip-backup)
      SKIP_BACKUP=true
      shift
      ;;
    --skip-sysupdate)
      SKIP_SYSUPDATE=true
      shift
      ;;
    -h|--help)
      showhelp_install
      exit 0
      ;;
    *)
      echo -e "${STY_RED}Unknown option: $1${STY_RST}"
      showhelp_install
      exit 1
      ;;
  esac
done
