# Core functions for ii-niri installer
# This is NOT a script for execution, but for loading functions

# shellcheck shell=bash

function try { "$@" || sleep 0; }

function v(){
  echo -e "####################################################"
  echo -e "${STY_BLUE}[$0]: Next command:${STY_RST}"
  echo -e "${STY_GREEN}$*${STY_RST}"
  local execute=true
  if $ask;then
    while true;do
      echo -e "${STY_BLUE}Execute? ${STY_RST}"
      echo "  y = Yes"
      echo "  e = Exit now"
      echo "  s = Skip this command"
      echo "  yesforall = Yes and don't ask again"
      local p; read -p "====> " p
      case $p in
        [yY]) echo -e "${STY_BLUE}OK, executing...${STY_RST}" ;break ;;
        [eE]) echo -e "${STY_BLUE}Exiting...${STY_RST}" ;exit ;break ;;
        [sS]) echo -e "${STY_BLUE}Alright, skipping...${STY_RST}" ;execute=false ;break ;;
        "yesforall") echo -e "${STY_BLUE}Alright, won't ask again.${STY_RST}"; ask=false ;break ;;
        *) echo -e "${STY_RED}Please enter [y/e/s/yesforall].${STY_RST}";;
      esac
    done
  fi
  if $execute;then x "$@";else
    echo -e "${STY_YELLOW}[$0]: Skipped \"$*\"${STY_RST}"
  fi
}

function x(){
  if "$@";then local cmdstatus=0;else local cmdstatus=1;fi
  while [ $cmdstatus == 1 ] ;do
    echo -e "${STY_RED}[$0]: Command \"${STY_GREEN}$*${STY_RED}\" has failed."
    echo -e "You may need to resolve the problem manually.${STY_RST}"
    echo "  r = Repeat this command (DEFAULT)"
    echo "  e = Exit now"
    echo "  i = Ignore this error and continue"
    local p; read -p " [R/e/i]: " p
    case $p in
      [iI]) echo -e "${STY_BLUE}Alright, ignoring...${STY_RST}";cmdstatus=2;;
      [eE]) echo -e "${STY_BLUE}Exiting...${STY_RST}";break;;
      *) echo -e "${STY_BLUE}Repeating...${STY_RST}"
         if "$@";then cmdstatus=0;else cmdstatus=1;fi
         ;;
    esac
  done
  case $cmdstatus in
    0) echo -e "${STY_BLUE}[$0]: Command \"${STY_GREEN}$*${STY_BLUE}\" finished.${STY_RST}";;
    1) echo -e "${STY_RED}[$0]: Command \"${STY_GREEN}$*${STY_RED}\" failed. Exiting...${STY_RST}";exit 1;;
    2) echo -e "${STY_RED}[$0]: Command \"${STY_GREEN}$*${STY_RED}\" failed but ignored.${STY_RST}";;
  esac
}

function showfun(){
  echo -e "${STY_BLUE}[$0]: Function \"$1\":${STY_RST}"
  printf "${STY_GREEN}"
  type -a "$1" 2>/dev/null || return 1
  printf "${STY_RST}"
}

function pause(){
  if [ ! "$ask" == "false" ];then
    printf "${STY_FAINT}${STY_SLANT}"
    local p; read -p "(Ctrl-C to abort, Enter to proceed)" p
    printf "${STY_RST}"
  fi
}

function prevent_sudo_or_root(){
  case $(whoami) in
    root) echo -e "${STY_RED}[$0]: Do NOT run as root. Aborting...${STY_RST}";exit 1;;
  esac
}

function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

function log_info() {
  echo -e "${STY_BLUE}[INFO]${STY_RST} $1"
}

function log_success() {
  echo -e "${STY_GREEN}[OK]${STY_RST} $1"
}

function log_warning() {
  echo -e "${STY_YELLOW}[WARN]${STY_RST} $1"
}

function log_error() {
  echo -e "${STY_RED}[ERROR]${STY_RST} $1" >&2
}

function log_header() {
  echo -e "\n${STY_PURPLE}=== $1 ===${STY_RST}"
}

# File operations for 3.files.sh
cp_file(){
  x mkdir -p "$(dirname $2)"
  x cp -f "$1" "$2"
  x mkdir -p "$(dirname ${INSTALLED_LISTFILE})"
  realpath -se "$2" >> "${INSTALLED_LISTFILE}"
}

rsync_dir(){
  x mkdir -p "$2"
  local dest="$(realpath -se $2)"
  x mkdir -p "$(dirname ${INSTALLED_LISTFILE})"
  rsync -a --out-format='%i %n' "$1"/ "$2"/ | awk -v d="$dest" '$1 ~ /^>/{ sub(/^[^ ]+ /,""); printf d "/" $0 "\n" }' >> "${INSTALLED_LISTFILE}"
}

rsync_dir__sync(){
  x mkdir -p "$2"
  local dest="$(realpath -se $2)"
  x mkdir -p "$(dirname ${INSTALLED_LISTFILE})"
  rsync -a --delete --out-format='%i %n' "$1"/ "$2"/ | awk -v d="$dest" '$1 ~ /^>/{ sub(/^[^ ]+ /,""); printf d "/" $0 "\n" }' >> "${INSTALLED_LISTFILE}"
}

function install_file(){
  local s=$1
  local t=$2
  if [ -f $t ];then
    echo -e "${STY_YELLOW}[$0]: \"$t\" will be overwritten.${STY_RST}"
  fi
  v cp_file $s $t
}

function install_file__auto_backup(){
  local s=$1
  local t=$2
  if [ -f $t ];then
    echo -e "${STY_YELLOW}[$0]: \"$t\" exists.${STY_RST}"
    if ${INSTALL_FIRSTRUN};then
      echo -e "${STY_BLUE}[$0]: First run - backing up.${STY_RST}"
      v mv $t $t.old
      v cp_file $s $t
    else
      echo -e "${STY_BLUE}[$0]: Not first run - saving as .new${STY_RST}"
      v cp_file $s $t.new
    fi
  else
    echo -e "${STY_GREEN}[$0]: \"$t\" does not exist.${STY_RST}"
    v cp_file $s $t
  fi
}

function install_dir(){
  local s=$1
  local t=$2
  if [ -d $t ];then
    echo -e "${STY_YELLOW}[$0]: \"$t\" will be merged.${STY_RST}"
  fi
  rsync_dir $s $t
}

function install_dir__sync(){
  local s=$1
  local t=$2
  if [ -d $t ];then
    echo -e "${STY_YELLOW}[$0]: \"$t\" will be synced (--delete).${STY_RST}"
  fi
  rsync_dir__sync $s $t
}

function install_dir__skip_existed(){
  local s=$1
  local t=$2
  if [ -d $t ];then
    echo -e "${STY_BLUE}[$0]: \"$t\" exists, skipping.${STY_RST}"
  else
    echo -e "${STY_YELLOW}[$0]: \"$t\" does not exist.${STY_RST}"
    v rsync_dir $s $t
  fi
}

function backup_clashing_targets(){
  local source_dir="$1"
  local target_dir="$2"
  local backup_dir="$3"
  local -a ignored_list=("${@:4}")

  local clash_list=()
  local source_list=($(ls -A "$source_dir" 2>/dev/null))
  local target_list=($(ls -A "$target_dir" 2>/dev/null))
  local -A target_map
  for i in "${target_list[@]}"; do
    target_map["$i"]=1
  done
  for i in "${source_list[@]}"; do
    if [[ -n "${target_map[$i]}" ]]; then
      clash_list+=("$i")
    fi
  done

  local args_includes=()
  for i in "${clash_list[@]}"; do
    if [[ -d "$target_dir/$i" ]]; then
      args_includes+=(--include="/$i/")
      args_includes+=(--include="/$i/**")
    else
      args_includes+=(--include="/$i")
    fi
  done
  args_includes+=(--exclude='*')

  if [ ${#clash_list[@]} -gt 0 ]; then
    x mkdir -p $backup_dir
    x rsync -av --progress "${args_includes[@]}" "$target_dir/" "$backup_dir/"
  fi
}

function dedup_and_sort_listfile(){
  if ! test -f "$1"; then
    echo "File not found: $1" >&2; return 2
  else
    temp="$(mktemp)"
    sort -u -- "$1" > "$temp"
    mv -f -- "$temp" "$2"
  fi
}
