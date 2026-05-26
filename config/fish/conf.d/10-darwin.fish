if test (uname) = Darwin
    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    else if test -x /usr/local/bin/brew
        eval (/usr/local/bin/brew shellenv)
    else
        __dotfiles_add_path /opt/homebrew/bin
        __dotfiles_add_path /opt/homebrew/sbin
        __dotfiles_add_path /usr/local/bin
        __dotfiles_add_path /usr/local/sbin
    end
end
