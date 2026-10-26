# Dotfiles

My personal desktop and development environment for Ubuntu 24.04. The setup
uses Sway, Zsh, and Neovim, with GNU Stow keeping configuration files linked
to this repository.

## Install

Start with a fresh Ubuntu 24.04 account and a checkout of this repository at
`~/dotfiles`. Installation requires network access and sudo.

Review the personal defaults before installing, particularly the
[Git identity](stow/.gitconfig), [desktop configuration](stow/.config/sway/config),
and [package list](scripts/packages.sh).

Preview the setup:

```bash
cd "$HOME/dotfiles"
./install.sh --check
```

This checks configuration and symlink conflicts and reports available tools.
It makes no changes and needs neither sudo nor network access. Some validation
checks are skipped when their tools are unavailable.

**Save any settings you need from `~/.profile` first:** the installer replaces
an existing regular file without a backup. Other unmanaged files are preserved;
resolve any reported conflicts before continuing.

Install:

```bash
./install.sh
```

The installer installs packages and development tools, links the configuration,
sets Zsh as the default shell, and applies system-wide settings. Reboot afterward
to apply the shell and lid-switch changes.

## Use

Logging in locally on TTY1 starts Sway automatically. `Super` is the Windows
or logo key.

| Shortcut | Action |
| --- | --- |
| `Super+Return` | Open a terminal |
| `Super+d` | Open the application launcher |
| `Super+n` | Open the file manager |
| `Super+i` | Open the browser |
| `Super+1` … `Super+0` | Switch workspaces |
| `Super+Shift+q` | Close the focused window |
| `Super+Shift+c` | Reload the desktop configuration |

See the [Sway configuration](stow/.config/sway/config) for the full set of
bindings. Open Neovim with `nvim`; its plugins and formatters are provisioned
on startup. Run `claude` or `codex` to sign in before using either CLI.

### Configure displays

Sway uses the connected displays' default modes and scaling. Put machine-specific
preferences in `~/.config/sway/local.conf`, which is excluded from Git and Stow.
Find display names with:

```bash
swaymsg -t get_outputs
```

For example, to adjust a display's scale, add:

```text
output DP-1 scale 1.25
```

Run `swaymsg reload` to apply the change.

## Manage configuration

The repository is organized into three directories:

- [`stow/`](stow/) mirrors your home directory and contains the managed configuration.
- [`system/`](system/) contains system-wide settings installed with sudo.
- [`scripts/`](scripts/) contains installation helpers and checks.

The whole `stow/` directory is one Stow package. For example,
`stow/.zshrc` links to `~/.zshrc`. Edit managed files directly; their symlinks
point back into this checkout. Application-generated state is left unmanaged.

After adding or moving files, recreate the links:

```bash
cd "$HOME/dotfiles"
stow --no-folding --dir="$HOME/dotfiles" --target="$HOME" --restow stow
```

The installer also does this automatically.

To bring an existing `~/.config/foo/` into the repository, use the helper:

```bash
./scripts/add-stow-config.sh foo
git add stow/.config/foo
git commit -m "Add foo config"
```

It moves the configuration into `stow/.config/foo/` and restows the package.

## Validate changes

Run `./install.sh --check` to check the setup without installing anything.
When changing the installation scripts, also run the syntax and regression
checks (requires Python 3 and GNU Stow):

```bash
bash -n install.sh
bash -n scripts/*.sh
python3 -B -m unittest discover -s scripts/tests
```

These checks do not exercise package installation, downloads, builds, or desktop
startup. Verify changes to those steps on a disposable fresh Ubuntu installation.
