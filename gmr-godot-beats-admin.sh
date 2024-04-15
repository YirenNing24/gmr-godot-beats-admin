#!/bin/sh
echo -ne '\033c\033]0;gmr-godot-beats-admin\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/gmr-godot-beats-admin.x86_64" "$@"
