if command -sq starship
    starship init fish | source
end

# Only pay for pyenv (~70ms) when it manages at least one Python version.
set -l __dotfiles_pyenv_versions $HOME/.pyenv/versions/*
if command -sq pyenv; and set -q __dotfiles_pyenv_versions[1]
    # --no-rehash: skip regenerating shims on every shell start (run `pyenv rehash` after installs).
    pyenv init - --no-rehash fish | source
end

if command -sq zoxide
    zoxide init fish | source
    alias cd=z
end

if command -sq fzf
    fzf --fish | source
end

# Homebrew ships its own direnv hook in vendor_conf.d; only hook here where none exists.
if command -sq direnv; and not path is -f $__fish_vendor_confdirs/direnv.fish
    direnv hook fish | source
end

if command -sq nvim
    alias vim=nvim
end

if command -sq eza
    alias ls=eza
end

if status is-interactive
    ulimit -n 65536 >/dev/null 2>&1
end
