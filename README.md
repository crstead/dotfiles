# Dotfiles

Personal Ubuntu 24.04 dotfiles and machine setup.

## Install

Run:

```bash
./install.sh
```

Include optional apps with:

```bash
./install.sh --extras
```

## Stow layout

Application configs use a flattened layout.

```text
~/dotfiles/stow/kitty/kitty.conf
→ ~/.config/kitty/kitty.conf
```

```text
~/dotfiles/stow/nvim/init.lua
→ ~/.config/nvim/init.lua
```

Home-level packages target `$HOME`:

```text
~/dotfiles/stow/zsh/.zshrc
→ ~/.zshrc
```

## Add a new app config

For an app whose config lives at:

```text
~/.config/foo/
```

run:

```bash
./scripts/add-stow-config.sh foo
```

The helper moves the config into:

```text
~/dotfiles/stow/foo/
```

and Stows it back into:

```text
~/.config/foo/
```

Then commit it:

```bash
git add stow/foo
git commit -m "Add foo config"
```

## Restow

The main installer runs Stow automatically.

To run only the Stow setup:

```bash
bash -c '
  DOTFILES_DIR="$HOME/dotfiles"
  export DOTFILES_DIR
  source "$DOTFILES_DIR/scripts/stow.sh"
  stow_dotfiles
'
```

## Validate

```bash
bash -n install.sh
bash -n scripts/*.sh
```

Verify a managed file with:

```bash
readlink -f ~/.config/nvim/init.lua
```
