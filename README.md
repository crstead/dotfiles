# Dotfiles

Personal Ubuntu 24.04 dotfiles and machine setup.

## Install

Run:

```bash id="jj49p1"
./install.sh
```

The installer includes the desktop applications used by this setup: Firefox,
Thunar and its archive tools, Pavucontrol, Galculator, and Okular.

Check the setup before installing:

```bash
./install.sh --check
```

Checks validate source files, shell syntax, Firefox policy JSON, and Stow
conflicts, and report which tools and installations are present. They make no
changes, require no sudo, and use no network access. An existing `.profile`
is reported as a planned backup, matching the installer's behavior.

Exit status is nonzero when a check finds an error. Missing validation tools
are reported as skipped checks; missing installation dependencies are listed
without failing the check. This does not test downloads, package availability,
builds, or privileged operations.

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
stow --no-folding --dir="$HOME/dotfiles" --target="$HOME" --restow stow
```

Individual file links keep application-generated state outside the repository.
Go telemetry and the PulseAudio authentication cookie are excluded from both
Git and Stow.

## Review changes in Neovim

CodeDiff loads on demand with `:CodeDiff` or `Space gd`. Open it in a Git
repository to review staged, unstaged, and untracked changes while an AI agent
works. The explorer refreshes automatically; `R` refreshes it manually.
These views include all local changes, regardless of who made them.

- `Space gf`: compare the current file with HEAD.
- `]c` / `[c`: next / previous change.
- `]f` / `[f`: next / previous file.
- `q`: close the diff tab.

Lazy installs the plugin on startup. CodeDiff downloads its native diff library
on first use; `:CodeDiff install` installs it explicitly.

Mason Tool Installer provisions the formatters configured in Conform on startup.
Run `:MasonToolsInstall` to retry missing tools. Python formatters require
`python3-venv`, which the system installer includes.

## Validate

Check shell syntax:

```bash id="5btcn5"
bash -n install.sh
bash -n scripts/*.sh
```

Run the config migration regression checks in temporary directories:

```bash
python3 -B -m unittest discover -s scripts/tests
```

Verify a managed file:

```bash id="6wbvye"
readlink -f "$HOME/.config/nvim/init.lua"
```

It should resolve somewhere under:

```text id="59b4n4"
$HOME/dotfiles/stow/
```
