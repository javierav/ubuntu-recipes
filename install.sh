#!/usr/bin/env bash

VERSION="0.0.1"

# shellcheck disable=SC2034
{
  OFF='\033[0m'
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
}

run_command() {
  timestamp=$(date +%Y-%m-%d\ %H:%M)
  echo -e "\n\n$timestamp - Running command $1\n" >> /root/install-debug.log
  eval "$1 >> /root/install-debug.log 2> /dev/null"
}

print_status() {
  echo -n -e "  * $1 "
}

print_ok() {
  echo "[OK]"
}

version() {
  echo "$VERSION"
}

usage() {
  cat << EOF

  Usage: $0 [options]

  OPTIONS:
    --skip-dotfiles  no install custom dotfiles
    --skip-dotvim    no install custom vim config
    --skip-tools     no install system default tools
    -v               print script version
    -h               print this help

EOF
}

parse_options() {
  for option in "$@"; do
    case ${option} in
      --skip-dotfiles)
        SKIP_DOTFILES=true
        ;;
      --skip-dotvim)
        SKIP_DOTVIM=true
        ;;
      --skip-tools)
        SKIP_TOOLS=true
        ;;
      -v)
        version
        exit 1
        ;;
      -h)
        usage
        exit 1
        ;;
    esac
  done
}

parse_options "$@"

echo "Running server-config install script ..."

print_status "Updating system"
  run_command "apt update"
  run_command "apt upgrade -y"
print_ok

if [ -z "$SKIP_DOTFILES" ]; then
  print_status "Installing github.com/javierav/dotfiles"
    if [ -d "/root/.dotfiles" ]; then
      run_command "rm -fr \"/root/.dotfiles\""
    fi

    run_command "cd \"/root\""
    run_command "git clone https://github.com/javierav/dotfiles.git .dotfiles"
    run_command "cd \"/root/.dotfiles\""
    run_command "./install.sh -f -s railsrc -s rubocop.yml -s Xdefaults"
    run_command "git config --global --remove-section user"
  print_ok
fi

if [ -z "$SKIP_DOTVIM" ]; then
  print_status "Installing github.com/javierav/dotvim"
    if [ -d "/root/.vim" ]; then
      run_command "rm -fr \"/root/.vim\""
    fi

    run_command "cd \"/root\""
    run_command "git clone https://github.com/javierav/dotvim.git .vim"
    run_command "cd \"/root/.vim\""
    run_command "git submodule update --init"
  print_ok
fi

if [ -z "$SKIP_TOOLS" ]; then
  print_status "Installing basic tools"
    run_command "apt install -y vim mc iptraf-ng curl wget tree"
  print_ok
fi