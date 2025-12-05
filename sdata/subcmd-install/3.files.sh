# Config file installation for ii-niri
# This script is meant to be sourced.

# shellcheck shell=bash

if ! ${quiet:-false}; then
  printf "${STY_CYAN}[$0]: 3. Copying config files${STY_RST}\n"
fi

#####################################################################################
# Ensure directories exist
#####################################################################################
for dir in "$XDG_BIN_HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"; do
  if ! test -e "$dir"; then
    v mkdir -p "$dir"
  fi
done

# Create quickshell state directories
v mkdir -p "${XDG_STATE_HOME}/quickshell/user/generated/wallpaper"
v mkdir -p "${XDG_CACHE_HOME}/quickshell"

#####################################################################################
# Determine first run
#####################################################################################
case "${INSTALL_FIRSTRUN}" in
  true) sleep 0 ;;
  *)
    if test -f "${FIRSTRUN_FILE}"; then
      INSTALL_FIRSTRUN=false
    else
      INSTALL_FIRSTRUN=true
    fi
    ;;
esac

#####################################################################################
# Backup existing configs
#####################################################################################
function auto_backup_configs(){
  local backup=false
  case $ask in
    false) if [[ ! -d "$BACKUP_DIR" ]]; then local backup=true;fi;;
    *)
      printf "${STY_YELLOW}"
      printf "Would you like to backup existing configs to \"$BACKUP_DIR\"?\n"
      printf "${STY_RST}"
      while true;do
        echo "  y = Yes, backup"
        echo "  n = No, skip"
        local p; read -p "====> " p
        case $p in
          [yY]) local backup=true;break ;;
          [nN]) local backup=false;break ;;
          *) echo -e "${STY_RED}Please enter [y/n].${STY_RST}";;
        esac
      done
      ;;
  esac
  if $backup;then
    backup_clashing_targets dots/.config $XDG_CONFIG_HOME "${BACKUP_DIR}/.config"
    printf "${STY_BLUE}Backup finished: ${BACKUP_DIR}${STY_RST}\n"
  fi
}

if [[ ! "${SKIP_BACKUP}" == true ]]; then auto_backup_configs; fi

#####################################################################################
# Install Quickshell config (ii)
#####################################################################################
case "${SKIP_QUICKSHELL}" in
  true) sleep 0;;
  *)
    if ! ${quiet:-false}; then
      echo -e "${STY_CYAN}Installing Quickshell ii config...${STY_RST}"
    fi
    
    # The ii QML code is in the root of this repo, not in dots/
    # We copy it to ~/.config/quickshell/ii/
    II_SOURCE="${REPO_ROOT}"
    II_TARGET="${XDG_CONFIG_HOME}/quickshell/ii"
    
    # Files/dirs to copy (QML code and assets)
    QML_ITEMS=(
      shell.qml
      GlobalStates.qml
      FamilyTransitionOverlay.qml
      killDialog.qml
      settings.qml
      welcome.qml
      modules
      services
      scripts
      assets
      translations
      requirements.txt
    )
    
    v mkdir -p "$II_TARGET"
    
    for item in "${QML_ITEMS[@]}"; do
      if [[ -d "${II_SOURCE}/${item}" ]]; then
        install_dir__sync "${II_SOURCE}/${item}" "${II_TARGET}/${item}"
      elif [[ -f "${II_SOURCE}/${item}" ]]; then
        install_file "${II_SOURCE}/${item}" "${II_TARGET}/${item}"
      fi
    done
    
    log_success "Quickshell ii config installed"
    ;;
esac

#####################################################################################
# Install config files from dots/
#####################################################################################
if ! ${quiet:-false}; then
  echo -e "${STY_CYAN}Installing config files from dots/...${STY_RST}"
fi

# Niri config
case "${SKIP_NIRI}" in
  true) sleep 0;;
  *)
    if [[ -f "defaults/niri/config.kdl" ]]; then
      install_file__auto_backup "defaults/niri/config.kdl" "${XDG_CONFIG_HOME}/niri/config.kdl"
      log_success "Niri config installed (defaults)"
    elif [[ -d "dots/.config/niri" ]]; then
      install_file__auto_backup "dots/.config/niri/config.kdl" "${XDG_CONFIG_HOME}/niri/config.kdl"
      log_success "Niri config installed (dots)"
    fi
    
    # Migrate: Add layer-rules for backdrop if missing (required for Niri overview)
    NIRI_CONFIG="${XDG_CONFIG_HOME}/niri/config.kdl"
    if [[ -f "$NIRI_CONFIG" ]]; then
      if ! grep -q "quickshell:iiBackdrop" "$NIRI_CONFIG" 2>/dev/null; then
        if ! ${quiet:-false}; then
          echo -e "${STY_CYAN}Adding backdrop layer-rules to Niri config...${STY_RST}"
        fi
        cat >> "$NIRI_CONFIG" << 'BACKDROP_RULES'

// ============================================================================
// Layer rules added by ii setup (required for backdrop in Niri overview)
// ============================================================================
layer-rule {
    match namespace="quickshell:iiBackdrop"
    place-within-backdrop true
    opacity 1.0
}

layer-rule {
    match namespace="quickshell:wBackdrop"
    place-within-backdrop true
    opacity 1.0
}
BACKDROP_RULES
        log_success "Backdrop layer-rules added to Niri config"
      fi
      
      # NOTE: Keybind migration removed - too fragile and causes duplicates
      # The defaults/niri/config.kdl already has all ii keybinds.
      # On first install: user gets the full config
      # On update: user keeps their config, new defaults go to .new
      # Users can manually merge keybinds from .new if needed
      
      # Only show a hint if this is an update and .new was created
      if [[ "${IS_UPDATE}" == "true" && -f "${NIRI_CONFIG}.new" ]] && ! ${quiet:-false}; then
        echo -e "${STY_YELLOW}Note: New keybinds may be available in ${NIRI_CONFIG}.new${STY_RST}"
        echo -e "${STY_YELLOW}Compare with: diff ~/.config/niri/config.kdl ~/.config/niri/config.kdl.new${STY_RST}"
      fi
      
      # Migrate: Add //off to animations block if missing (required for GameMode toggle)
      if ! grep -qE '^\s*(//)?off' "$NIRI_CONFIG" 2>/dev/null; then
        if ! ${quiet:-false}; then
          echo -e "${STY_CYAN}Adding //off to animations block for GameMode support...${STY_RST}"
        fi
        python3 << 'MIGRATE_ANIMATIONS'
import re
import os

config_path = os.path.expanduser("~/.config/niri/config.kdl")
with open(config_path, 'r') as f:
    content = f.read()

# Check if //off already exists in animations block
animations_match = re.search(r'^animations\s*\{([^}]*)\}', content, re.MULTILINE | re.DOTALL)
if animations_match:
    block_content = animations_match.group(1)
    if '//off' not in block_content and 'off' not in block_content:
        # Insert //off after animations {
        new_block = 'animations {\n    //off' + block_content + '}'
        content = content[:animations_match.start()] + new_block + content[animations_match.end():]
        with open(config_path, 'w') as f:
            f.write(content)
# Output suppressed - shell handles logging
MIGRATE_ANIMATIONS
        log_success "Added //off to animations block"
      fi
      
      # Migrate: Replace native close-window with closeConfirm script
      if grep -q 'Mod+Q.*close-window' "$NIRI_CONFIG" 2>/dev/null; then
        if ! ${quiet:-false}; then
          echo -e "${STY_CYAN}Migrating Mod+Q to use closeConfirm...${STY_RST}"
        fi
        python3 << 'MIGRATE_CLOSEWINDOW'
import re
import os

config_path = os.path.expanduser("~/.config/niri/config.kdl")
with open(config_path, 'r') as f:
    content = f.read()

# Replace Mod+Q close-window with our script
pattern = r'Mod\+Q[^}]*close-window[^}]*\}'
replacement = 'Mod+Q repeat=false { spawn "bash" "-c" "$HOME/.config/quickshell/ii/scripts/close-window.sh"; }'
content = re.sub(pattern, replacement, content)

with open(config_path, 'w') as f:
    f.write(content)
# Output suppressed in quiet mode (checked by shell)
MIGRATE_CLOSEWINDOW
        log_success "Mod+Q migrated to closeConfirm with fallback"
      fi
      
      # Migrate: Qt theming - use kde platform + Darkly style for proper Qt app theming
      if grep -q 'QT_QPA_PLATFORMTHEME "gtk3"' "$NIRI_CONFIG" 2>/dev/null; then
        if ! ${quiet:-false}; then
          echo -e "${STY_CYAN}Migrating Qt theming to use Darkly...${STY_RST}"
        fi
        # Change gtk3 to kde for kdeglobals color support
        sed -i 's/QT_QPA_PLATFORMTHEME "gtk3"/QT_QPA_PLATFORMTHEME "kde"/' "$NIRI_CONFIG"
        # Remove QT_QPA_PLATFORMTHEME_QT6 if present (not needed with kde)
        sed -i '/QT_QPA_PLATFORMTHEME_QT6/d' "$NIRI_CONFIG"
        # Add QT_STYLE_OVERRIDE if not present
        if ! grep -q 'QT_STYLE_OVERRIDE' "$NIRI_CONFIG" 2>/dev/null; then
          sed -i '/QT_QPA_PLATFORMTHEME "kde"/a\    QT_STYLE_OVERRIDE "Darkly"' "$NIRI_CONFIG"
        fi
        log_success "Qt theming migrated to Darkly"
      fi
    fi
    ;;
esac

# Matugen (theming)
if [[ -d "dots/.config/matugen" ]]; then
  install_dir__sync "dots/.config/matugen" "${XDG_CONFIG_HOME}/matugen"
  log_success "Matugen config installed"
fi

# Fuzzel (launcher)
if [[ -d "dots/.config/fuzzel" ]]; then
  install_dir__sync "dots/.config/fuzzel" "${XDG_CONFIG_HOME}/fuzzel"
  log_success "Fuzzel config installed"
fi

# GTK settings
for gtkver in gtk-3.0 gtk-4.0; do
  if [[ -d "dots/.config/${gtkver}" ]]; then
    install_dir "dots/.config/${gtkver}" "${XDG_CONFIG_HOME}/${gtkver}"
  fi
done

# KDE settings (for Dolphin and Qt apps)
if [[ -f "defaults/kde/kdeglobals" ]]; then
  install_file__auto_backup "defaults/kde/kdeglobals" "${XDG_CONFIG_HOME}/kdeglobals"
elif [[ -f "dots/.config/kdeglobals" ]]; then
  install_file__auto_backup "dots/.config/kdeglobals" "${XDG_CONFIG_HOME}/kdeglobals"
fi
if [[ -f "defaults/kde/dolphinrc" ]]; then
  install_file__auto_backup "defaults/kde/dolphinrc" "${XDG_CONFIG_HOME}/dolphinrc"
elif [[ -f "dots/.config/dolphinrc" ]]; then
  install_file__auto_backup "dots/.config/dolphinrc" "${XDG_CONFIG_HOME}/dolphinrc"
fi

# Kvantum (Qt theming)
if [[ -d "dots/.config/Kvantum" ]]; then
  install_dir "dots/.config/Kvantum" "${XDG_CONFIG_HOME}/Kvantum"
fi

# Copy Colloid theme to user Kvantum folder if installed
if [[ -d "/usr/share/Kvantum/Colloid" ]]; then
  if ! ${quiet:-false}; then
    echo -e "${STY_CYAN}Setting up Kvantum Colloid theme...${STY_RST}"
  fi
  mkdir -p "${XDG_CONFIG_HOME}/Kvantum/Colloid"
  cp -r /usr/share/Kvantum/Colloid/* "${XDG_CONFIG_HOME}/Kvantum/Colloid/"
  log_success "Kvantum Colloid theme configured"
fi

# Setup MaterialAdw folder for dynamic theming
mkdir -p "${XDG_CONFIG_HOME}/Kvantum/MaterialAdw"
if [[ -f "${XDG_CONFIG_HOME}/Kvantum/Colloid/ColloidDark.kvconfig" ]]; then
  cp "${XDG_CONFIG_HOME}/Kvantum/Colloid/ColloidDark.kvconfig" "${XDG_CONFIG_HOME}/Kvantum/MaterialAdw/MaterialAdw.kvconfig"
fi

# Fontconfig
if [[ -d "dots/.config/fontconfig" ]]; then
  install_dir__sync "dots/.config/fontconfig" "${XDG_CONFIG_HOME}/fontconfig"
fi

# illogical-impulse config.json
if [[ -f "dots/.config/illogical-impulse/config.json" ]]; then
  install_file__auto_backup "dots/.config/illogical-impulse/config.json" "${XDG_CONFIG_HOME}/illogical-impulse/config.json"
elif [[ -f "defaults/config.json" ]]; then
  # Fallback to defaults
  v mkdir -p "${XDG_CONFIG_HOME}/illogical-impulse"
  install_file__auto_backup "defaults/config.json" "${XDG_CONFIG_HOME}/illogical-impulse/config.json"
fi

#####################################################################################
# Mark first run complete
#####################################################################################
function gen_firstrun(){
  x mkdir -p "$(dirname ${FIRSTRUN_FILE})"
  x touch "${FIRSTRUN_FILE}"
  x mkdir -p "$(dirname ${INSTALLED_LISTFILE})"
  realpath -se "${FIRSTRUN_FILE}" >> "${INSTALLED_LISTFILE}"
}

v gen_firstrun
v dedup_and_sort_listfile "${INSTALLED_LISTFILE}" "${INSTALLED_LISTFILE}"

#####################################################################################
# Environment variables are configured in Niri
#####################################################################################
if ! ${quiet:-false}; then
  echo -e "${STY_CYAN}Configuring environment variables...${STY_RST}"
fi

# Note: ILLOGICAL_IMPULSE_VIRTUAL_ENV is set in ~/.config/niri/config.kdl
# in the environment {} block. This is the proper way for Niri/Wayland compositors.
# The Niri config has been installed with this variable already set.

# Verify the variable will be available after Niri restart
if grep -q "ILLOGICAL_IMPULSE_VIRTUAL_ENV" "${XDG_CONFIG_HOME}/niri/config.kdl" 2>/dev/null; then
    log_success "Environment variable configured in Niri config"
else
    echo -e "${STY_YELLOW}Warning: ILLOGICAL_IMPULSE_VIRTUAL_ENV not found in Niri config${STY_RST}"
    echo -e "${STY_YELLOW}Quickshell may not work correctly until you add it to ~/.config/niri/config.kdl${STY_RST}"
fi

# Clean up legacy shell-specific files from previous versions
for legacy_file in \
    "${XDG_CONFIG_HOME}/fish/conf.d/ii-niri-env.fish" \
    "${XDG_CONFIG_HOME}/ii-niri-env.sh" \
    "${XDG_CONFIG_HOME}/environment.d/60-ii-niri.conf"
do
    if [[ -f "$legacy_file" ]]; then
        rm -f "$legacy_file"
        log_success "Removed legacy config: $(basename $legacy_file)"
    fi
done

# Clean up legacy lines in shell rc files
if [[ -f "$HOME/.bashrc" ]]; then
    if grep -q "ii-niri-env.sh" "$HOME/.bashrc"; then
        sed -i '/ii-niri-env.sh/d' "$HOME/.bashrc"
        log_success "Cleaned up .bashrc"
    fi
fi
if [[ -f "$HOME/.zshrc" ]]; then
    if grep -q "ii-niri-env.sh" "$HOME/.zshrc"; then
        sed -i '/ii-niri-env.sh/d' "$HOME/.zshrc"
        log_success "Cleaned up .zshrc"
    fi
fi

# Fix Qt Icons (Apply GTK icon theme to KDE/Qt globals)
# This ensures Qt apps use the same icons as GTK apps
GTK_SETTINGS="${XDG_CONFIG_HOME}/gtk-3.0/settings.ini"
KDE_GLOBALS="${XDG_CONFIG_HOME}/kdeglobals"

if [[ -f "$GTK_SETTINGS" ]]; then
    ICON_THEME=$(grep "gtk-icon-theme-name" "$GTK_SETTINGS" | cut -d= -f2 | xargs)
    if [[ -n "$ICON_THEME" ]]; then
        if ! ${quiet:-false}; then
          echo -e "${STY_CYAN}Applying icon theme '$ICON_THEME' to Qt/KDE...${STY_RST}"
        fi
        
        # Ensure [Icons] section exists
        if ! grep -q "\[Icons\]" "$KDE_GLOBALS" 2>/dev/null; then
            mkdir -p "$(dirname "$KDE_GLOBALS")"
            echo -e "\n[Icons]" >> "$KDE_GLOBALS"
        fi
        
        # Update or add Theme key
        if grep -q "Theme=" "$KDE_GLOBALS"; then
            sed -i "s/^Theme=.*/Theme=$ICON_THEME/" "$KDE_GLOBALS"
        else
            # Insert after [Icons]
            sed -i "/\[Icons\]/a Theme=$ICON_THEME" "$KDE_GLOBALS"
        fi
        log_success "Qt icon theme configured"
    fi
fi

#####################################################################################
# Set default wallpaper and generate initial theme
#####################################################################################
DEFAULT_WALLPAPER="${II_TARGET}/assets/wallpapers/qs-niri.jpg"
if [[ "${INSTALL_FIRSTRUN}" == true && -f "${DEFAULT_WALLPAPER}" ]]; then
  if ! ${quiet:-false}; then
    echo -e "${STY_CYAN}Setting default wallpaper...${STY_RST}"
  fi
  
  # Ensure output directories exist for matugen
  mkdir -p "${XDG_STATE_HOME}/quickshell/user/generated"
  mkdir -p "${XDG_STATE_HOME}/quickshell/user/generated/wallpaper"
  mkdir -p "${XDG_CONFIG_HOME}/gtk-3.0"
  mkdir -p "${XDG_CONFIG_HOME}/gtk-4.0"
  mkdir -p "${XDG_CONFIG_HOME}/fuzzel"
  
  # Update config.json with default wallpaper path
  if [[ -f "${XDG_CONFIG_HOME}/illogical-impulse/config.json" ]]; then
    if command -v jq >/dev/null 2>&1; then
      jq --arg path "${DEFAULT_WALLPAPER}" '.background.wallpaperPath = $path' \
        "${XDG_CONFIG_HOME}/illogical-impulse/config.json" > "${XDG_CONFIG_HOME}/illogical-impulse/config.json.tmp" \
        && mv "${XDG_CONFIG_HOME}/illogical-impulse/config.json.tmp" "${XDG_CONFIG_HOME}/illogical-impulse/config.json"
      log_success "Default wallpaper configured"
    fi
  fi
  
  # Generate initial theme colors with matugen
  export ILLOGICAL_IMPULSE_VIRTUAL_ENV="${XDG_STATE_HOME}/quickshell/.venv"
  if command -v matugen >/dev/null 2>&1; then
    if ! ${quiet:-false}; then
      echo -e "${STY_CYAN}Generating theme colors from wallpaper...${STY_RST}"
    fi
    # Use --config to ensure correct config file is used
    if matugen image "${DEFAULT_WALLPAPER}" --mode dark --config "${XDG_CONFIG_HOME}/matugen/config.toml" 2>&1; then
      log_success "Theme colors generated"
    else
      log_warning "Matugen failed to generate colors. Theme may not work correctly."
    fi
  else
    log_warning "Matugen not installed. GTK/Qt theming will not be applied."
  fi
fi

#####################################################################################
# Reset first run marker
#####################################################################################
QUICKSHELL_FIRST_RUN_FILE="${XDG_STATE_HOME}/quickshell/user/first_run.txt"
if [[ "${INSTALL_FIRSTRUN}" == true ]]; then
  if [[ -f "${QUICKSHELL_FIRST_RUN_FILE}" ]]; then
    x rm -f "${QUICKSHELL_FIRST_RUN_FILE}"
  fi
fi

#####################################################################################
# Final status checks
#####################################################################################
WARNINGS=()

if ! command -v niri >/dev/null; then
  WARNINGS+=("Niri compositor not found in PATH")
fi

if [[ ! -f "${XDG_CONFIG_HOME}/niri/config.kdl" ]]; then
  WARNINGS+=("Niri config not found at ~/.config/niri/config.kdl")
fi

if ! command -v qs >/dev/null; then
  WARNINGS+=("Quickshell (qs) not found in PATH")
fi

if ! command -v matugen >/dev/null; then
  WARNINGS+=("Matugen not found - theming may not work")
fi

#####################################################################################
# Final Summary
#####################################################################################

# In quiet mode, just print a simple status line
if ${quiet:-false}; then
  if [[ "${IS_UPDATE}" == "true" ]]; then
    echo "ii-niri: update complete"
  else
    echo "ii-niri: install complete"
  fi
else
  echo ""
  echo ""

  if [[ "${IS_UPDATE}" == "true" ]]; then
    # Update-specific output
    printf "${STY_GREEN}${STY_BOLD}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                    ✓ Update Complete                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    printf "${STY_RST}"
    echo ""

    echo -e "${STY_BLUE}${STY_BOLD}┌─ What was updated${STY_RST}"
    echo -e "${STY_BLUE}│${STY_RST}"
    echo -e "${STY_BLUE}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Quickshell ii synced to ~/.config/quickshell/ii/"
    echo -e "${STY_BLUE}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Missing keybinds added to Niri config (if any)"
    echo -e "${STY_BLUE}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Config migrations applied"
    echo -e "${STY_BLUE}│${STY_RST}"
    echo -e "${STY_BLUE}└──────────────────────────────${STY_RST}"
    echo ""
  else
    # Install output
    printf "${STY_GREEN}${STY_BOLD}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                  ✓ Installation Complete                     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    printf "${STY_RST}"
    echo ""

    echo -e "${STY_BLUE}${STY_BOLD}┌─ What was installed${STY_RST}"
    echo -e "${STY_BLUE}│${STY_RST}"
    echo -e "${STY_BLUE}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Quickshell ii copied to ~/.config/quickshell/ii/"
    echo -e "${STY_BLUE}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Niri config with ii keybindings"
    echo -e "${STY_BLUE}│${STY_RST}  ${STY_GREEN}✓${STY_RST} GTK/Qt theming (Matugen + Kvantum + Darkly)"
    echo -e "${STY_BLUE}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Environment variables for ${DETECTED_SHELL:-your shell}"
    echo -e "${STY_BLUE}│${STY_RST}  ${STY_GREEN}✓${STY_RST} Default wallpaper and color scheme"
    echo -e "${STY_BLUE}│${STY_RST}"
    echo -e "${STY_BLUE}└──────────────────────────────${STY_RST}"
    echo ""
  fi
fi

# Skip the rest of the summary in quiet mode
if ! ${quiet:-false}; then

  # Check for .new files that need manual review
  NEW_FILES=()
  for f in "${XDG_CONFIG_HOME}/niri/config.kdl.new" \
           "${XDG_CONFIG_HOME}/illogical-impulse/config.json.new" \
           "${XDG_CONFIG_HOME}/kdeglobals.new"; do
    if [[ -f "$f" ]]; then
      NEW_FILES+=("$f")
    fi
  done

  if [[ ${#NEW_FILES[@]} -gt 0 ]]; then
    echo -e "${STY_YELLOW}${STY_BOLD}┌─ Files to Review${STY_RST}"
    echo -e "${STY_YELLOW}│${STY_RST}"
    echo -e "${STY_YELLOW}│${STY_RST}  New defaults saved as .new (your config preserved):"
    for f in "${NEW_FILES[@]}"; do
      echo -e "${STY_YELLOW}│${STY_RST}    ${STY_FAINT}${f}${STY_RST}"
    done
    echo -e "${STY_YELLOW}│${STY_RST}"
    echo -e "${STY_YELLOW}│${STY_RST}  Compare with: ${STY_FAINT}diff <file> <file>.new${STY_RST}"
    echo -e "${STY_YELLOW}└──────────────────────────${STY_RST}"
    echo ""
  fi

  # Show warnings if any
  if [[ ${#WARNINGS[@]} -gt 0 ]]; then
    echo -e "${STY_YELLOW}${STY_BOLD}┌─ Warnings${STY_RST}"
    echo -e "${STY_YELLOW}│${STY_RST}"
    for warn in "${WARNINGS[@]}"; do
      echo -e "${STY_YELLOW}│${STY_RST}  ${STY_RED}⚠${STY_RST} ${warn}"
    done
    echo -e "${STY_YELLOW}│${STY_RST}"
    echo -e "${STY_YELLOW}└──────────────────────────────${STY_RST}"
    echo ""
  fi

  # Next steps
  echo -e "${STY_CYAN}${STY_BOLD}┌─ Next Steps${STY_RST}"
  echo -e "${STY_CYAN}│${STY_RST}"
  echo -e "${STY_CYAN}│${STY_RST}  ${STY_BOLD}1.${STY_RST} Log out and select ${STY_BOLD}Niri${STY_RST} at your display manager"
  echo -e "${STY_CYAN}│${STY_RST}  ${STY_BOLD}2.${STY_RST} ii will start automatically with your session"
  echo -e "${STY_CYAN}│${STY_RST}"
  echo -e "${STY_CYAN}│${STY_RST}  Or reload now if already in Niri:"
  echo -e "${STY_CYAN}│${STY_RST}  ${STY_FAINT}$ niri msg action load-config-file${STY_RST}"
  echo -e "${STY_CYAN}│${STY_RST}"
  echo -e "${STY_CYAN}└──────────────────────────────${STY_RST}"
  echo ""

  # Key shortcuts (only show on install, not update)
  if [[ "${IS_UPDATE}" != "true" ]]; then
    echo -e "${STY_PURPLE}${STY_BOLD}┌─ Key Shortcuts${STY_RST}"
    echo -e "${STY_PURPLE}│${STY_RST}"
    echo -e "${STY_PURPLE}│${STY_RST}  ${STY_INVERT} Super+Space ${STY_RST}     Search / Overview"
    echo -e "${STY_PURPLE}│${STY_RST}  ${STY_INVERT} Super+G ${STY_RST}         Overlay (widgets, tools)"
    echo -e "${STY_PURPLE}│${STY_RST}  ${STY_INVERT} Alt+Tab ${STY_RST}         Window switcher"
    echo -e "${STY_PURPLE}│${STY_RST}  ${STY_INVERT} Super+V ${STY_RST}         Clipboard history"
    echo -e "${STY_PURPLE}│${STY_RST}  ${STY_INVERT} Ctrl+Alt+T ${STY_RST}      Wallpaper picker"
    echo -e "${STY_PURPLE}│${STY_RST}  ${STY_INVERT} Super+/ ${STY_RST}         Show all shortcuts"
    echo -e "${STY_PURPLE}│${STY_RST}"
    echo -e "${STY_PURPLE}└──────────────────────────────${STY_RST}"
    echo ""
  fi

  echo -e "${STY_FAINT}Backups saved to: ${BACKUP_DIR}${STY_RST}"
  echo -e "${STY_FAINT}Logs: qs log -c ii${STY_RST}"
  echo ""

  if [[ "${IS_UPDATE}" == "true" ]]; then
    echo -e "${STY_GREEN}Done. Hot reload should kick in any second now.${STY_RST}"
  else
    echo -e "${STY_GREEN}Enjoy your new desktop!${STY_RST}"
  fi
  echo ""

fi  # end quiet check
