# Dotfiles

Personal Ubuntu 24.04 dotfiles and machine setup.

## Install

Run:

```bash id="jj49p1"
./install.sh
```

Include optional apps with:

```bash id="n7t40l"
./install.sh --extras
```

## Stow layout

`$HOME/dotfiles/stow/` mirrors `$HOME`.

For example:

```text id="pf0d8q"
$HOME/dotfiles/stow/.config/kitty/kitty.conf
→ $HOME/.config/kitty/kitty.conf
```

```text id="xw7stc"
$HOME/dotfiles/stow/.config/nvim/init.lua
→ $HOME/.config/nvim/init.lua
```

```text id="2g5q76"
$HOME/dotfiles/stow/.zshrc
→ $HOME/.zshrc
```

The entire `stow` directory is one GNU Stow package.

## Add a new app config

For an app whose config lives at:

```text id="eklsjb"
$HOME/.config/foo/
```

run:

```bash id="npp49i"
./scripts/add-stow-config.sh foo
```

The helper moves it into:

```text id="i2wy3t"
$HOME/dotfiles/stow/.config/foo/
```

and restows the dotfiles package.

Then commit it:

```bash id="gp447t"
git add stow/.config/foo
git commit -m "Add foo config"
```

## Restow

The installer restows dotfiles automatically.

Manually:

```bash id="vsl7dx"
cd "$HOME/dotfiles"
stow --dir="$HOME/dotfiles" --target="$HOME" --restow stow
```

## Validate

Check shell syntax:

```bash id="5btcn5"
bash -n install.sh
bash -n scripts/*.sh
```

Verify a managed file:

```bash id="6wbvye"
readlink -f "$HOME/.config/nvim/init.lua"
```

It should resolve somewhere under:

```text id="59b4n4"
$HOME/dotfiles/stow/
```
