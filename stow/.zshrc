# Keep local tools ahead of system binaries, including in non-login terminals.
typeset -U path
path=("$HOME/.local/bin" $path)
if command -v go >/dev/null 2>&1; then
  path=("$(go env GOPATH)/bin" $path)
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

export EDITOR=nvim
export VISUAL=nvim
alias nmr='sudo systemctl restart NetworkManager'
