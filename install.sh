#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

dotfiles=()

add_dotfile() {
    dotfiles+=("$1|$2|$3|$4")
}

# Types:
# - dir: copy all contents from a repo directory into a destination directory
# - file: copy one repo file to one destination file
add_dotfile atuin  dir  atuin      "$config_home/atuin"
add_dotfile btop   dir  btop       "$config_home/btop"
add_dotfile kitty  dir  kitty      "$config_home/kitty"
add_dotfile nvim   dir  nvim       "$config_home/nvim"
add_dotfile sway   dir  sway       "$config_home/sway"
add_dotfile tofi   dir  tofi       "$config_home/tofi"
add_dotfile waybar dir  waybar     "$config_home/waybar"
add_dotfile yazi   dir  yazi       "$config_home/yazi"
add_dotfile zsh    file zsh/zshrc  "$HOME/.zshrc"

copy_dotdir() {
    local source_dir="$1"
    local destination_dir="$2"

    mkdir -p -- "$destination_dir"
    cp -rip -- "$repo_dir/$source_dir"/. "$destination_dir"/
}

copy_dotfile() {
    local source_path="$1"
    local destination_path="$2"

    mkdir -p -- "$(dirname -- "$destination_path")"
    cp -ip -- "$repo_dir/$source_path" "$destination_path"
}

available_dotfiles() {
    local names=""
    local entry name

    for entry in "${dotfiles[@]}"; do
        IFS='|' read -r name _ _ _ <<< "$entry"
        names="$names $name"
    done

    echo "${names# }"
}

install_dotfile() {
    local requested="$1"
    local entry name type source_path destination_path

    for entry in "${dotfiles[@]}"; do
        IFS='|' read -r name type source_path destination_path <<< "$entry"
        if [ "$name" = "$requested" ]; then
            case "$type" in
                dir) copy_dotdir "$source_path" "$destination_path" ;;
                file) copy_dotfile "$source_path" "$destination_path" ;;
                *)
                    echo "Unknown type for $name: $type" >&2
                    exit 1
                    ;;
            esac
            return
        fi
    done

    echo "Unknown dotfile: $requested" >&2
    echo "Available: $(available_dotfiles)" >&2
    exit 1
}

if [ "$#" -eq 0 ]; then
    set -- $(available_dotfiles)
fi

for dotfile in "$@"; do
    install_dotfile "$dotfile"
done
