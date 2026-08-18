# dotfiles

My personal Linux dotfiles.

## Install everything

```sh
./install.py install
```

## Install specific configs

Pass one or more names as arguments:

```sh
./install.py install nvim kitty waybar
```

## Preview, list, or check drift / differences

```sh
./install.py install --dry-run
./install.py list
./install.py check
./install.py diff
```

`check` reports files that only exist in the repo, only exist on the system, or differ between both locations. Positional arguments are always target names, so future config names cannot conflict with script actions.
