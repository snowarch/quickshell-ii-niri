# Migration system for ii-niri
# Respects user configs - never modifies without explicit consent
# This script is meant to be sourced.

# shellcheck shell=bash

#####################################################################################
# Migration System Configuration
#####################################################################################
MIGRATIONS_DIR="${REPO_ROOT}/sdata/migrations"
MIGRATIONS_STATE_FILE="${XDG_CONFIG_HOME}/illogical-impulse/migrations.json"
MIGRATIONS_BACKUP_DIR="${XDG_CONFIG_HOME}/illogical-impulse/backups"
VERSION_FILE="${XDG_CONFIG_HOME}/illogical-impulse/version"

# Current version - update this with each release
CURRENT_VERSION="2.0.0"

#####################################################################################
# Version Management
#####################################################################################
get_installed_version() {
  if [[ -f "$VERSION_FILE" ]]; then
    cat "$VERSION_FILE"
  else
    echo "0.0.0"
  fi
}

set_installed_version() {
  local version="$1"
  mkdir -p "$(dirname "$VERSION_FILE")"
  echo "$version" > "$VERSION_FILE"
}

#####################################################################################
# Migration State Management
#####################################################################################
init_migrations_state() {
  if [[ ! -f "$MIGRATIONS_STATE_FILE" ]]; then
    mkdir -p "$(dirname "$MIGRATIONS_STATE_FILE")"
    echo '{"applied": [], "skipped": []}' > "$MIGRATIONS_STATE_FILE"
  fi
}

is_migration_applied() {
  local migration_id="$1"
  init_migrations_state
  if command -v jq &>/dev/null; then
    jq -e ".applied | index(\"$migration_id\")" "$MIGRATIONS_STATE_FILE" &>/dev/null
  else
    grep -q "\"$migration_id\"" "$MIGRATIONS_STATE_FILE" 2>/dev/null
  fi
}

is_migration_skipped() {
  local migration_id="$1"
  init_migrations_state
  if command -v jq &>/dev/null; then
    jq -e ".skipped | index(\"$migration_id\")" "$MIGRATIONS_STATE_FILE" &>/dev/null
  else
    false
  fi
}

mark_migration_applied() {
  local migration_id="$1"
  init_migrations_state
  if command -v jq &>/dev/null; then
    local tmp=$(mktemp)
    jq ".applied += [\"$migration_id\"] | .applied |= unique" "$MIGRATIONS_STATE_FILE" > "$tmp"
    mv "$tmp" "$MIGRATIONS_STATE_FILE"
  fi
}

mark_migration_skipped() {
  local migration_id="$1"
  init_migrations_state
  if command -v jq &>/dev/null; then
    local tmp=$(mktemp)
    jq ".skipped += [\"$migration_id\"] | .skipped |= unique" "$MIGRATIONS_STATE_FILE" > "$tmp"
    mv "$tmp" "$MIGRATIONS_STATE_FILE"
  fi
}

#####################################################################################
# Backup System
#####################################################################################
create_backup() {
  local file="$1"
  local backup_name="$2"
  
  if [[ ! -f "$file" ]]; then
    return 1
  fi
  
  local timestamp=$(date +%Y-%m-%d-%H%M%S)
  local backup_dir="${MIGRATIONS_BACKUP_DIR}/${timestamp}"
  mkdir -p "$backup_dir"
  
  local filename=$(basename "$file")
  cp "$file" "${backup_dir}/${backup_name:-$filename}"
  
  echo "$backup_dir"
}

list_backups() {
  if [[ -d "$MIGRATIONS_BACKUP_DIR" ]]; then
    ls -1t "$MIGRATIONS_BACKUP_DIR" 2>/dev/null | head -20
  fi
}

restore_backup() {
  local backup_timestamp="$1"
  local backup_dir="${MIGRATIONS_BACKUP_DIR}/${backup_timestamp}"
  
  if [[ ! -d "$backup_dir" ]]; then
    echo -e "${STY_RED}Backup not found: $backup_timestamp${STY_RST}"
    return 1
  fi
  
  echo -e "${STY_CYAN}Restoring from backup: $backup_timestamp${STY_RST}"
  
  for file in "$backup_dir"/*; do
    local filename=$(basename "$file")
    local target=""
    
    case "$filename" in
      niri-config.kdl) target="${XDG_CONFIG_HOME}/niri/config.kdl" ;;
      config.json) target="${XDG_CONFIG_HOME}/illogical-impulse/config.json" ;;
      *) continue ;;
    esac
    
    if [[ -n "$target" ]]; then
      cp "$file" "$target"
      echo -e "${STY_GREEN}  Restored: $target${STY_RST}"
    fi
  done
  
  echo -e "${STY_GREEN}Backup restored successfully${STY_RST}"
}

#####################################################################################
# Migration Discovery
#####################################################################################
list_available_migrations() {
  if [[ ! -d "$MIGRATIONS_DIR" ]]; then
    return
  fi
  
  for migration_file in "$MIGRATIONS_DIR"/*.sh; do
    if [[ -f "$migration_file" ]]; then
      basename "$migration_file" .sh
    fi
  done | sort -V
}

get_pending_migrations() {
  local pending=()
  
  for migration_id in $(list_available_migrations); do
    if ! is_migration_applied "$migration_id" && ! is_migration_skipped "$migration_id"; then
      pending+=("$migration_id")
    fi
  done
  
  echo "${pending[@]}"
}

count_pending_migrations() {
  local count=0
  for migration_id in $(list_available_migrations); do
    if ! is_migration_applied "$migration_id" && ! is_migration_skipped "$migration_id"; then
      ((count++))
    fi
  done
  echo "$count"
}

#####################################################################################
# Migration Execution
#####################################################################################
load_migration() {
  local migration_id="$1"
  local migration_file="${MIGRATIONS_DIR}/${migration_id}.sh"
  
  if [[ ! -f "$migration_file" ]]; then
    echo -e "${STY_RED}Migration not found: $migration_id${STY_RST}"
    return 1
  fi
  
  # Reset migration variables
  MIGRATION_ID=""
  MIGRATION_TITLE=""
  MIGRATION_DESCRIPTION=""
  MIGRATION_TARGET_FILE=""
  MIGRATION_REQUIRED=false
  
  source "$migration_file"
}

show_migration_preview() {
  local migration_id="$1"
  
  load_migration "$migration_id" || return 1
  
  echo ""
  echo -e "${STY_CYAN}${STY_BOLD}┌─ Migration: ${MIGRATION_ID}${STY_RST}"
  echo -e "${STY_CYAN}│${STY_RST}"
  echo -e "${STY_CYAN}│${STY_RST}  ${STY_BOLD}Title:${STY_RST} ${MIGRATION_TITLE}"
  echo -e "${STY_CYAN}│${STY_RST}  ${STY_BOLD}File:${STY_RST}  ${MIGRATION_TARGET_FILE}"
  echo -e "${STY_CYAN}│${STY_RST}"
  echo -e "${STY_CYAN}│${STY_RST}  ${MIGRATION_DESCRIPTION}"
  echo -e "${STY_CYAN}│${STY_RST}"
  
  if type migration_preview &>/dev/null; then
    echo -e "${STY_CYAN}│${STY_RST}  ${STY_BOLD}Changes:${STY_RST}"
    migration_preview | while IFS= read -r line; do
      echo -e "${STY_CYAN}│${STY_RST}    $line"
    done
    echo -e "${STY_CYAN}│${STY_RST}"
  fi
  
  echo -e "${STY_CYAN}└──────────────────────────────${STY_RST}"
}

apply_migration() {
  local migration_id="$1"
  local force="${2:-false}"
  
  load_migration "$migration_id" || return 1
  
  # Check if already applied
  if is_migration_applied "$migration_id" && [[ "$force" != "true" ]]; then
    echo -e "${STY_YELLOW}Migration already applied: $migration_id${STY_RST}"
    return 0
  fi
  
  # Check if target file exists
  local target_file="${MIGRATION_TARGET_FILE/#\~/$HOME}"
  if [[ -n "$target_file" && ! -f "$target_file" ]]; then
    echo -e "${STY_YELLOW}Target file not found, skipping: $target_file${STY_RST}"
    mark_migration_skipped "$migration_id"
    return 0
  fi
  
  # Create backup
  if [[ -n "$target_file" && -f "$target_file" ]]; then
    local backup_dir=$(create_backup "$target_file" "$(basename "$target_file")")
    echo -e "${STY_BLUE}Backup created: $backup_dir${STY_RST}"
  fi
  
  # Apply migration
  if type migration_apply &>/dev/null; then
    if migration_apply; then
      mark_migration_applied "$migration_id"
      echo -e "${STY_GREEN}✓ Migration applied: $migration_id${STY_RST}"
      return 0
    else
      echo -e "${STY_RED}✗ Migration failed: $migration_id${STY_RST}"
      if [[ -n "$backup_dir" ]]; then
        echo -e "${STY_YELLOW}  Restoring from backup...${STY_RST}"
        cp "${backup_dir}/$(basename "$target_file")" "$target_file"
      fi
      return 1
    fi
  else
    echo -e "${STY_RED}Migration has no apply function: $migration_id${STY_RST}"
    return 1
  fi
}

#####################################################################################
# Interactive Migration UI
#####################################################################################
run_migrations_interactive() {
  local pending=($(get_pending_migrations))
  
  if [[ ${#pending[@]} -eq 0 ]]; then
    echo -e "${STY_GREEN}No pending migrations.${STY_RST}"
    return 0
  fi
  
  echo ""
  echo -e "${STY_PURPLE}${STY_BOLD}╔══════════════════════════════════════════════════════════════╗${STY_RST}"
  echo -e "${STY_PURPLE}${STY_BOLD}║              ii-niri Configuration Migrations                ║${STY_RST}"
  echo -e "${STY_PURPLE}${STY_BOLD}╚══════════════════════════════════════════════════════════════╝${STY_RST}"
  echo ""
  echo -e "${STY_CYAN}Found ${#pending[@]} pending migration(s).${STY_RST}"
  echo -e "${STY_CYAN}These will update your config files to support new features.${STY_RST}"
  echo -e "${STY_CYAN}Your original files will be backed up automatically.${STY_RST}"
  echo ""
  
  for migration_id in "${pending[@]}"; do
    show_migration_preview "$migration_id"
    
    echo ""
    echo -e "${STY_YELLOW}Apply this migration?${STY_RST}"
    echo "  y = Yes, apply"
    echo "  n = No, skip (won't ask again)"
    echo "  v = View full diff"
    echo "  a = Apply all remaining"
    echo "  q = Quit"
    
    while true; do
      read -p "====> " choice
      case "$choice" in
        [yY])
          apply_migration "$migration_id"
          break
          ;;
        [nN])
          mark_migration_skipped "$migration_id"
          echo -e "${STY_YELLOW}Skipped: $migration_id${STY_RST}"
          break
          ;;
        [vV])
          if type migration_diff &>/dev/null; then
            load_migration "$migration_id"
            migration_diff
          else
            echo -e "${STY_YELLOW}No diff available for this migration${STY_RST}"
          fi
          ;;
        [aA])
          apply_migration "$migration_id"
          for remaining in "${pending[@]}"; do
            if ! is_migration_applied "$remaining" && ! is_migration_skipped "$remaining"; then
              apply_migration "$remaining"
            fi
          done
          return 0
          ;;
        [qQ])
          echo -e "${STY_BLUE}Migrations paused. Run './setup migrate' to continue later.${STY_RST}"
          return 0
          ;;
        *)
          echo -e "${STY_RED}Please enter y/n/v/a/q${STY_RST}"
          ;;
      esac
    done
  done
  
  echo ""
  echo -e "${STY_GREEN}All migrations processed.${STY_RST}"
}

run_migrations_auto() {
  local pending=($(get_pending_migrations))
  
  for migration_id in "${pending[@]}"; do
    load_migration "$migration_id"
    if [[ "$MIGRATION_REQUIRED" == "true" ]]; then
      apply_migration "$migration_id"
    fi
  done
}

#####################################################################################
# Migration Status Display
#####################################################################################
show_migrations_status() {
  echo ""
  echo -e "${STY_CYAN}${STY_BOLD}Migration Status${STY_RST}"
  echo ""
  
  local applied=0
  local skipped=0
  local pending=0
  
  for migration_id in $(list_available_migrations); do
    if is_migration_applied "$migration_id"; then
      echo -e "  ${STY_GREEN}✓${STY_RST} $migration_id"
      ((applied++))
    elif is_migration_skipped "$migration_id"; then
      echo -e "  ${STY_YELLOW}○${STY_RST} $migration_id (skipped)"
      ((skipped++))
    else
      echo -e "  ${STY_BLUE}●${STY_RST} $migration_id (pending)"
      ((pending++))
    fi
  done
  
  echo ""
  echo -e "Applied: $applied | Skipped: $skipped | Pending: $pending"
}
