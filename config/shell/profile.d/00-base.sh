dotfiles_add_path "$HOME/.local/bin"
dotfiles_add_path "$HOME/.cargo/bin"
dotfiles_add_path "$HOME/go/bin"

if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    dotfiles_add_path "$PYENV_ROOT/bin"
fi

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
