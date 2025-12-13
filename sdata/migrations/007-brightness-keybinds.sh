# Migration: Add brightness keybinds
# Hardware brightness keys with OSD

MIGRATION_ID="007-brightness-keybinds"
MIGRATION_TITLE="Brightness Hardware Keys"
MIGRATION_DESCRIPTION="Adds XF86MonBrightnessUp/Down keybinds that use ii-niri IPC.
  Shows on-screen display when changing brightness."
MIGRATION_TARGET_FILE="~/.config/niri/config.kdl"
MIGRATION_REQUIRED=false

migration_check() {
  local config="${XDG_CONFIG_HOME}/niri/config.kdl"
  [[ -f "$config" ]] && ! grep -q 'XF86MonBrightnessUp' "$config"
}

migration_preview() {
  echo -e "${STY_GREEN}+ XF86MonBrightnessUp { spawn \"qs\" \"-c\" \"ii\" \"ipc\" \"call\" \"brightness\" \"increment\"; }${STY_RST}"
  echo -e "${STY_GREEN}+ XF86MonBrightnessDown { spawn \"qs\" \"-c\" \"ii\" \"ipc\" \"call\" \"brightness\" \"decrement\"; }${STY_RST}"
}

migration_apply() {
  local config="${XDG_CONFIG_HOME}/niri/config.kdl"
  
  if ! migration_check; then
    return 0
  fi
  
  # Find a good place to add (after audio keybinds or at end of binds section)
  if grep -q 'XF86Audio' "$config"; then
    # Add after last XF86Audio keybind
    sed -i '/XF86Audio.*}/a\    \n    // Brightness (hardware keys)\n    XF86MonBrightnessUp { spawn "qs" "-c" "ii" "ipc" "call" "brightness" "increment"; }\n    XF86MonBrightnessDown { spawn "qs" "-c" "ii" "ipc" "call" "brightness" "decrement"; }' "$config"
  else
    # Append to binds section
    cat >> "$config" << 'KEYBINDS'

// Brightness (hardware keys) - added by ii-niri
binds {
    XF86MonBrightnessUp { spawn "qs" "-c" "ii" "ipc" "call" "brightness" "increment"; }
    XF86MonBrightnessDown { spawn "qs" "-c" "ii" "ipc" "call" "brightness" "decrement"; }
}
KEYBINDS
  fi
}
