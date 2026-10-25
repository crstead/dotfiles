# Dotfiles

Personal Ubuntu 24.04 dotfiles and machine setup.

## Install

Run:

```bash id="jj49p1"
./install.sh
```

The installer includes the desktop applications used by this setup: Firefox,
Thunar and its archive tools, Pavucontrol, Galculator, and Okular.

Node/npm are managed by [nvm](https://github.com/nvm-sh/nvm). The installer
installs nvm when missing, installs the latest Node LTS release, and makes it
the default. Shell
configuration loads nvm before starting Sway and in interactive Zsh terminals.
Update with `nvm install --lts`; switch versions with `nvm use`. Opening a
terminal does not download updates.
Old symlinks created by the previous dotfiles Node installer are removed after
nvm successfully installs Node; its old distribution directories are left alone.

Tree-sitter requires CLI 0.26.1+; the installer downloads a checksummed 0.27.1
binary when necessary. That download supports Linux x86-64 and ARM64 and uses
`~/.local/bin`. `--check` reports nvm availability and tool versions on PATH
without loading nvm or downloading anything.

Check the setup before installing:

```bash
./install.sh --check
```

Checks validate source files, shell syntax, Firefox policy JSON, and Stow
conflicts, and report which tools and installations are present. They make no
changes, require no sudo, and use no network access.

For a fresh Ubuntu account, the installer replaces the existing regular
`~/.profile` with the repository version without keeping a backup. It verifies
that the replacement exists and checks all other Stow conflicts before removing
that file. An existing managed link is left to Stow; a `.profile` directory or
link elsewhere must be resolved manually. Other unmanaged files are preserved
and reported as conflicts. `--check` previews this behavior without removing
anything.

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

The dconf database, Thunar window geometry, and GTK bookmarks are also left
unmanaged because applications update them and bookmarks contain local paths.
Existing local copies are preserved.

## Displays

Sway uses the connected displays' default modes and scaling. Lid bindings
detect internal eDP, LVDS, and DSI panels at runtime and disable them only when
an external display is active.

Inspect the active displays from a terminal inside Sway:

```bash
swaymsg -t get_outputs
```

Put machine-specific scale and position preferences in
`~/.config/sway/local.conf`, which is excluded from Git and Stow. For example:

```text
output DP-1 scale 1.25
```

Use the connector name reported by Sway, or its quoted make/model/serial
identifier for a monitor that may move between ports. Reload with
`swaymsg reload` after editing. Scaling is a preference; resolution alone does
not determine the right value.

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

Run the focused regression checks in temporary directories (requires Python 3
and GNU Stow):

```bash
python3 -B -m unittest discover -s scripts/tests
```

The installer targets a fresh Ubuntu account. Tests cover profile replacement
and Stow conflicts, read-only validation, config migration and recovery, and
tool version/checksum handling. They protect against losing existing files or
accepting corrupt downloads; they do not mock a complete Ubuntu installation.
Package installation, downloads, builds, and desktop startup should be verified
on a disposable fresh Ubuntu installation when changing those steps.

Verify a managed file:

```bash id="6wbvye"
readlink -f "$HOME/.config/nvim/init.lua"
```

It should resolve somewhere under:

```text id="59b4n4"
$HOME/dotfiles/stow/
```
