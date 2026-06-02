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

if not set -q BUN_INSTALL
    set -gx BUN_INSTALL "$HOME/.bun"
end
__dotfiles_add_path "$BUN_INSTALL/bin"

if test -d "$HOME/.pyenv"
    set -gx PYENV_ROOT "$HOME/.pyenv"
    __dotfiles_add_path "$PYENV_ROOT/bin"
end

set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx NVM_DIR "$HOME/.nvm"

function __dotfiles_rustc_is_nightly
    command -q rustc; or return 1
    rustc -vV 2>/dev/null | string match -qr '^release: .*nightly'
end

if not set -q RUSTFLAGS; and __dotfiles_rustc_is_nightly
    set -gx RUSTFLAGS "-Z threads=12"
end

function __dotfiles_locale_available --argument-names candidate
    test -n "$candidate"; or return 1
    locale -a 2>/dev/null | string match -qi -- "$candidate"
end

set -l __dotfiles_locale_candidate
if set -q LC_ALL
    if __dotfiles_locale_available "$LC_ALL"
        set __dotfiles_locale_candidate "$LC_ALL"
    end
end

if test -z "$__dotfiles_locale_candidate"
    if set -q LANG
        if __dotfiles_locale_available "$LANG"
            set __dotfiles_locale_candidate "$LANG"
        end
    end
end

if test -z "$__dotfiles_locale_candidate"
    for candidate in en_US.UTF-8 en_US.utf8 C.UTF-8
        if __dotfiles_locale_available "$candidate"
            set __dotfiles_locale_candidate "$candidate"
            break
        end
    end
end

if test -n "$__dotfiles_locale_candidate"
    set -gx LANG "$__dotfiles_locale_candidate"
    set -gx LC_CTYPE "$__dotfiles_locale_candidate"
    set -gx LC_ALL "$__dotfiles_locale_candidate"
    set -gx LANGUAGE "$__dotfiles_locale_candidate"
end

set -e __dotfiles_locale_candidate
