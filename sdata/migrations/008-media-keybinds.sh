# Migration: Add media playback keybinds
# Hardware media keys with MPRIS integration

MIGRATION_ID="008-media-keybinds"
MIGRATION_TITLE="Media Playback Keys"
MIGRATION_DESCRIPTION="Adds XF86AudioPlay/Pause/Next/Prev keybinds for media control.
  Works with any MPRIS-compatible player (Spotify, Firefox, etc.)."
MIGRATION_TARGET_FILE="~/.config/niri/config.kdl"
MIGRATION_REQUIRED=false

migration_check() {
  local config="${XDG_CONFIG_HOME}/niri/config.kdl"
  [[ -f "$config" ]] && ! grep -q 'XF86AudioPlay' "$config"
}

migration_preview() {
  echo -e "${STY_GREEN}+ XF86AudioPlay { spawn \"qs\" ... \"mpris\" \"playPause\"; }${STY_RST}"
  echo -e "${STY_GREEN}+ XF86AudioPause { spawn \"qs\" ... \"mpris\" \"playPause\"; }${STY_RST}"
  echo -e "${STY_GREEN}+ XF86AudioNext { spawn \"qs\" ... \"mpris\" \"next\"; }${STY_RST}"
  echo -e "${STY_GREEN}+ XF86AudioPrev { spawn \"qs\" ... \"mpris\" \"previous\"; }${STY_RST}"
}

migration_apply() {
  local config="${XDG_CONFIG_HOME}/niri/config.kdl"
  
  if ! migration_check; then
    return 0
  fi
  
  # Find a good place to add
  if grep -q 'XF86MonBrightness' "$config"; then
    sed -i '/XF86MonBrightnessDown/a\    \n    // Media playback (hardware keys)\n    XF86AudioPlay { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "playPause"; }\n    XF86AudioPause { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "playPause"; }\n    XF86AudioNext { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "next"; }\n    XF86AudioPrev { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "previous"; }' "$config"
  elif grep -q 'XF86Audio' "$config"; then
    sed -i '/XF86Audio.*}/a\    \n    // Media playback (hardware keys)\n    XF86AudioPlay { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "playPause"; }\n    XF86AudioPause { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "playPause"; }\n    XF86AudioNext { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "next"; }\n    XF86AudioPrev { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "previous"; }' "$config"
  fi
}
