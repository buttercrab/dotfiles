# Environment needed by every fish, including scripts and `fish -c`.

# Only pay for pyenv (~70ms) when it manages at least one Python version.
set -l __dotfiles_pyenv_versions $HOME/.pyenv/versions/*
if command -sq pyenv; and set -q __dotfiles_pyenv_versions[1]
    # --no-rehash: skip regenerating shims on every shell start (run `pyenv rehash` after installs).
    pyenv init - --no-rehash fish | source
end

# Everything below only matters at a prompt.
status is-interactive; or return

if command -sq starship
    starship init fish | source
end

if command -sq zoxide
    # --cmd cd makes `cd` zoxide-aware (and adds `cdi`) the supported way, keeping `cd -` and completions.
    zoxide init fish --cmd cd | source
    abbr -a z cd
    abbr -a zi cdi
end

if command -sq fzf
    fzf --fish | source
end

# Homebrew ships its own direnv hook in vendor_conf.d; only hook here where none exists.
if command -sq direnv; and not path is -f $__fish_vendor_confdirs/direnv.fish
    direnv hook fish | source
end

# Abbreviations expand as you type, so history records the command that actually ran.
if command -sq nvim
    abbr -a vim nvim
end

if command -sq eza
    abbr -a ls eza
end

ulimit -n 65536 >/dev/null 2>&1
