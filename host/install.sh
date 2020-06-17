#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
NAME="io.github.tcode2k16.rofi.chrome"
TARGET_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"

cp "$DIR/$NAME.json" "$TARGET_DIR/$NAME.json"


HOST_PATH="$DIR/main.py"
ESCAPED_HOST_PATH=${HOST_PATH////\\/}
sed -i -e "s/HOST_PATH/$ESCAPED_HOST_PATH/" "$TARGET_DIR/$NAME.json"

chmod o+r "$TARGET_DIR/$NAME.json"
