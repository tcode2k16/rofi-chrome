#!/bin/bash
set -e

OS="$(uname -s)"
NAME="io.github.tcode2k16.rofi.chrome"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SOURCE_DIR/../host"

# colors
none='\033[0m'
bold='\033[1m'
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
magenta='\033[35m'
cyan='\033[36m'

main() {

  print_horizontal_line
  
  # OS
  case "$OS" in
  Linux)
    if command -v "google-chrome" >/dev/null 2>&1; then
      on_key 'Uninstall for google-chrome? (y/n)'
      if test "$key" = 'y'; then
        browser_uninstall "$HOME/.config/google-chrome/NativeMessagingHosts" "google-chrome"
      fi
    fi

    if command -v "chromium-browser" >/dev/null 2>&1; then
      on_key 'Uninstall for chromium-browser? (y/n)'
      if test "$key" = 'y'; then
        browser_uninstall "$HOME/.config/chromium/NativeMessagingHosts" "chromium-browser"
      fi
    fi

    ;;
  *)
    printf "${red}Error${none} %s is not currently supported" "$OS"
    ;;
  esac

}

browser_uninstall() {
  TARGET_DIR=$1
  browser_name=$2
  config_file="$TARGET_DIR/$NAME.json"
  if test -f "$config_file"; then
    rm "$config_file"
  fi

  printf "❯ ${green}Successfully uninstalled for %s ${none}\n" "$browser_name"
}

# Helpers

on_key() {
  prompt=$1
  printf "${blue}❯${none} $prompt\n"
  read -n 1 key </dev/tty
  printf '\r'
}

print_horizontal_line() {
  COLUMNS=$(tput cols)
  line=''
  index=0
  while test "$index" -lt "$COLUMNS"; do
    line="${line}─"
    index=$((index + 1))
  done
  printf '%s\n' "$line"
}

main "$@"
