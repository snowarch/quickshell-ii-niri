# Dependency installation router for ii-niri
# This script is meant to be sourced.

# shellcheck shell=bash

printf "${STY_CYAN}[$0]: 1. Install dependencies${STY_RST}\n"

#####################################################################################
# Route to the appropriate installer based on OS
#####################################################################################

if [[ "$OS_GROUP_ID" == "arch" ]]; then
  printf "./sdata/dist-arch/install-deps.sh will be used.\n"
  source ./sdata/dist-arch/install-deps.sh
else
  printf "${STY_RED}[$0]: Unsupported distribution: $OS_GROUP_ID${STY_RST}\n"
  printf "${STY_YELLOW}Currently only Arch-based systems are supported.${STY_RST}\n"
  printf "${STY_YELLOW}Please install dependencies manually and run with --skip-deps${STY_RST}\n"
  exit 1
fi
