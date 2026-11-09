function __dotfiles_add_path --argument-names dir
    if test -d "$dir"
        if not contains -- "$dir" $PATH
            set -gx PATH $dir $PATH
        end
    end
end

if not set -q BUN_INSTALL
    set -gx BUN_INSTALL "$HOME/.bun"
end

# Per-user tool dirs must beat Homebrew/system copies. The brew setup in 10-*.fish moves brew to the
# front, so it calls this again afterwards. Earlier arguments end up first on PATH.
function __dotfiles_front_user_paths
    fish_add_path --global --move --path $HOME/.local/bin $HOME/.cargo/bin $HOME/go/bin $BUN_INSTALL/bin
end
__dotfiles_front_user_paths

if test -d "$HOME/.pyenv"
    set -gx PYENV_ROOT "$HOME/.pyenv"
    __dotfiles_add_path "$PYENV_ROOT/bin"
end

set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx NVM_DIR "$HOME/.nvm"

# Locale: set LANG only. LC_ALL overrides every LC_* category and is meant for one-off debugging,
# so never set it here; just drop inherited values the system can't load (e.g. LC_CTYPE=UTF-8 over ssh).
set -g __dotfiles_locales (locale -a 2>/dev/null)

function __dotfiles_locale_available --argument-names candidate
    test -n "$candidate"; or return 1
    string match -qi -- "$candidate" $__dotfiles_locales
end

for __dotfiles_lc in LC_ALL LC_CTYPE
    if set -q $__dotfiles_lc; and not __dotfiles_locale_available "$$__dotfiles_lc"
        set -e $__dotfiles_lc
    end
end

if not __dotfiles_locale_available "$LANG"
    for candidate in en_US.UTF-8 en_US.utf8 C.UTF-8
        if __dotfiles_locale_available "$candidate"
            set -gx LANG "$candidate"
            break
        end
    end
end

functions -e __dotfiles_locale_available
set -e __dotfiles_locales
set -e __dotfiles_lc candidate
