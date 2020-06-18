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

  # setup
  chmod +x "$SOURCE_DIR/main.py"

  print_horizontal_line

  # Dependencies
  printf "${green}Checking Dependencies${none}: python2 rofi\n"

  check_dependency python2 Python2 https://www.python.org
  check_dependency rofi rofi https://github.com/davatorium/rofi
  
  print_horizontal_line
  
  # OS
  case "$OS" in
  Linux)
    if command -v "google-chrome" >/dev/null 2>&1; then
      on_key 'Install for google-chrome? (y/n)'
      if test "$key" = 'y'; then
        browser_install "$HOME/.config/google-chrome/NativeMessagingHosts" "google-chrome"
      fi
    fi

    if command -v "chromium-browser" >/dev/null 2>&1; then
      on_key 'Install for chromium-browser? (y/n)'
      if test "$key" = 'y'; then
        browser_install "$HOME/.config/chromium/NativeMessagingHosts" "chromium-browser"
      fi
    fi

    if command -v "firefox" >/dev/null 2>&1; then
      on_key 'Install for firefox? (y/n)'
      if test "$key" = 'y'; then
        browser_install "$HOME/.mozilla/native-messaging-hosts" "firefox"
      fi
    fi
    ;;
  *)
    printf "${red}Error${none} %s is not currently supported" "$OS"
    ;;
  esac

}

browser_install() {
  TARGET_DIR=$1
  browser_name=$2

  mkdir -p "$TARGET_DIR"

  cp "$SOURCE_DIR/$NAME.$browser_name.json" "$TARGET_DIR/$NAME.json"

  HOST_PATH="$SOURCE_DIR/main.py"
  ESCAPED_HOST_PATH=${HOST_PATH////\\/}
  sed -i -e "s/HOST_PATH/$ESCAPED_HOST_PATH/" "$TARGET_DIR/$NAME.json"


  chmod o+r "$TARGET_DIR/$NAME.json"
  printf "❯ ${green}Successfully installed for %s ${none}\n" "$browser_name"

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

check_dependency() {
  command=$1
  name=$2
  url=$3
  optional=${4:-no}
  if command -v "$command" >/dev/null 2>&1; then
    printf "❯ ${green}%s${none}\n" "$name"
  else
    printf "❯ ${red}%s${none}\n" "$name" >/dev/stderr
    printf 'Please install %s\n' "$name" >/dev/stderr
    printf '%s\n' "$url" >/dev/stderr
    if test "$optional" != yes; then
      exit 1
    fi
  fi
}

main "$@"
