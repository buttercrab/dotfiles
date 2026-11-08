if test (uname) = Darwin
    set -l __dotfiles_brew_prefix
    if test -x /opt/homebrew/bin/brew
        set __dotfiles_brew_prefix /opt/homebrew
    else if test -x /usr/local/bin/brew
        set __dotfiles_brew_prefix /usr/local
    end

    if test -n "$__dotfiles_brew_prefix"
        # Static equivalent of `brew shellenv fish`, which costs ~20ms per shell to spawn.
        # Re-check against `brew shellenv fish` if Homebrew changes what it sets.
        set -gx HOMEBREW_PREFIX $__dotfiles_brew_prefix
        set -gx HOMEBREW_CELLAR $__dotfiles_brew_prefix/Cellar
        if test $__dotfiles_brew_prefix = /usr/local
            set -gx HOMEBREW_REPOSITORY /usr/local/Homebrew
        else
            set -gx HOMEBREW_REPOSITORY $__dotfiles_brew_prefix
        end
        fish_add_path --global --move --path $__dotfiles_brew_prefix/bin $__dotfiles_brew_prefix/sbin
        if test -n "$MANPATH"
            set -gx MANPATH (string replace --regex '^:*(.*?):*$' ':$1' -- "$MANPATH")
        end
        set -q INFOPATH; or set INFOPATH ''
        set -gx INFOPATH $__dotfiles_brew_prefix/share/info $INFOPATH
    else
        __dotfiles_add_path /opt/homebrew/bin
        __dotfiles_add_path /opt/homebrew/sbin
        __dotfiles_add_path /usr/local/bin
        __dotfiles_add_path /usr/local/sbin
    end
end
