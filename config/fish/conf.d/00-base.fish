function __dotfiles_add_path --argument-names dir
    if test -d "$dir"
        if not contains -- "$dir" $PATH
            set -gx PATH $dir $PATH
        end
    end
end

__dotfiles_add_path "$HOME/.local/bin"
__dotfiles_add_path "$HOME/.cargo/bin"
__dotfiles_add_path "$HOME/go/bin"

if test -d "$HOME/.pyenv"
    set -gx PYENV_ROOT "$HOME/.pyenv"
    __dotfiles_add_path "$PYENV_ROOT/bin"
end

set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx NVM_DIR "$HOME/.nvm"
