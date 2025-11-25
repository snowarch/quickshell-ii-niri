# System setup for ii-niri
# This script is meant to be sourced.

# shellcheck shell=bash

printf "${STY_CYAN}[$0]: 2. System setup${STY_RST}\n"

#####################################################################################
# User groups
#####################################################################################
function setup_user_groups(){
  echo -e "${STY_BLUE}Setting up user groups...${STY_RST}"
  
  # i2c group for ddcutil (external monitor brightness)
  if [[ -z $(getent group i2c) ]]; then
    x sudo groupadd i2c
  fi
  
  # Add user to required groups
  x sudo usermod -aG video,i2c,input "$(whoami)"
  
  log_success "User added to video, i2c, input groups"
  log_warning "You may need to log out and back in for group changes to take effect"
}

#####################################################################################
# Systemd services
#####################################################################################
function setup_systemd_services(){
  echo -e "${STY_BLUE}Setting up systemd services...${STY_RST}"
  
  if [[ -z $(systemctl --version 2>/dev/null) ]]; then
    log_warning "systemctl not found, skipping service setup"
    return 0
  fi
  
  # i2c-dev module for ddcutil
  v bash -c "echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf"
  
  # ydotool service - create user service symlink if needed
  if [[ -f /usr/lib/systemd/system/ydotool.service ]]; then
    if [[ ! -e /usr/lib/systemd/user/ydotool.service ]]; then
      x sudo ln -sf /usr/lib/systemd/system/ydotool.service /usr/lib/systemd/user/ydotool.service
    fi
  fi
  
  # Enable ydotool
  if [[ ! -z "${DBUS_SESSION_BUS_ADDRESS}" ]]; then
    v systemctl --user daemon-reload
    v systemctl --user enable ydotool --now
  else
    log_warning "Not in a graphical session. Run this after login:"
    echo "  systemctl --user enable ydotool --now"
  fi
  
  # Bluetooth (optional)
  if command -v bluetoothctl &>/dev/null; then
    v sudo systemctl enable bluetooth --now
  fi
  
  log_success "Services configured"
}

#####################################################################################
# Super-tap daemon (tap Super key to toggle overview)
#####################################################################################
function setup_super_daemon(){
  echo -e "${STY_BLUE}Setting up Super-tap daemon...${STY_RST}"
  
  local daemon_src="${REPO_ROOT}/scripts/daemon/ii_super_overview_daemon.py"
  local service_src="${REPO_ROOT}/scripts/systemd/ii-super-overview.service"
  local daemon_dst="${HOME}/.local/bin/ii_super_overview_daemon.py"
  local service_dst="${XDG_CONFIG_HOME}/systemd/user/ii-super-overview.service"
  
  if [[ ! -f "$daemon_src" ]]; then
    log_warning "Super-tap daemon not found in repo, skipping"
    return 0
  fi
  
  # Install daemon script
  x mkdir -p "$(dirname "$daemon_dst")"
  x cp "$daemon_src" "$daemon_dst"
  x chmod +x "$daemon_dst"
  
  # Install systemd service
  x mkdir -p "$(dirname "$service_dst")"
  x cp "$service_src" "$service_dst"
  
  # Enable service if in graphical session
  if [[ ! -z "${DBUS_SESSION_BUS_ADDRESS}" ]]; then
    v systemctl --user daemon-reload
    v systemctl --user enable ii-super-overview.service --now
  else
    log_warning "Not in graphical session. Enable later with:"
    echo "  systemctl --user enable ii-super-overview.service --now"
  fi
  
  log_success "Super-tap daemon installed"
}

#####################################################################################
# GTK/KDE settings
#####################################################################################
function setup_desktop_settings(){
  echo -e "${STY_BLUE}Applying desktop settings...${STY_RST}"
  
  # gsettings for GNOME/GTK apps (Nautilus, etc.)
  if command -v gsettings &>/dev/null; then
    try gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    try gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    try gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
    try gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors-light'
    try gsettings set org.gnome.desktop.interface cursor-size 24
    try gsettings set org.gnome.desktop.interface font-name 'Rubik 11'
  fi
  
  # KDE/Qt settings (Dolphin, etc.)
  if command -v kwriteconfig6 &>/dev/null; then
    # Use Darkly widget style for KDE apps
    try kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Darkly
    # Set color scheme
    try kwriteconfig6 --file kdeglobals --group General --key ColorScheme MaterialYouDark
    # Set icons
    try kwriteconfig6 --file kdeglobals --group Icons --key Theme breeze-dark
  fi
  
  # Configure Kvantum theme via config file (avoid GUI)
  # kvantummanager --set can open a GUI window, so we write the config directly
  mkdir -p "${XDG_CONFIG_HOME}/Kvantum"
  echo -e "[General]\ntheme=Colloid-Dark" > "${XDG_CONFIG_HOME}/Kvantum/kvantum.kvconfig"
  
  log_success "Desktop settings applied"
}

#####################################################################################
# Run setups
#####################################################################################
showfun setup_user_groups
v setup_user_groups

showfun setup_systemd_services
v setup_systemd_services

showfun setup_desktop_settings
v setup_desktop_settings

# Super-tap daemon
showfun setup_super_daemon
v setup_super_daemon

# Python packages (in venv)
showfun install-python-packages
v install-python-packages
