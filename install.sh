#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

copy_dotdir() {
    local source_dir="$1"
    local destination_dir="$2"

    mkdir -p -- "$destination_dir"
    cp -rip -- "$repo_dir/$source_dir"/. "$destination_dir"/
}

copy_dotdir "autin" "$config_home/atuin"
copy_dotdir "btop" "$config_home/btop"
copy_dotdir "kitty" "$config_home/kitty"
copy_dotdir "nvim" "$config_home/nvim"
copy_dotdir "sway" "$config_home/sway"
copy_dotdir "tofi" "$config_home/tofi"
copy_dotdir "waybar" "$config_home/waybar"
copy_dotdir "yazi" "$config_home/yazi"
