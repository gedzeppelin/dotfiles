# dotfiles

My personal Linux dotfiles.

This repo is the source of truth for my configs. The included install script copies each config into its default location under `~/.config` using `cp -i`, so it asks before overwriting existing files.

## Install everything

```sh
./install.sh
```

## Install specific configs

Pass one or more names as arguments:

```sh
./install.sh nvim kitty waybar
```

Available names:

- `atuin`
- `btop`
- `kitty`
- `nvim`
- `sway`
- `tofi`
- `waybar`
- `yazi`
