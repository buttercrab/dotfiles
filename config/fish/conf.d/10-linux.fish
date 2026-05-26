if test (uname) = Linux
    if test -x /home/linuxbrew/.linuxbrew/bin/brew
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    else
        __dotfiles_add_path /home/linuxbrew/.linuxbrew/bin
        __dotfiles_add_path /home/linuxbrew/.linuxbrew/sbin
    end
end
