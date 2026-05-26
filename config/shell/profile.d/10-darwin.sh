case "$(uname -s)" in
    Darwin)
        ;;
    *)
        return 0
        ;;
esac

if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(SHELL=/bin/sh /opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(SHELL=/bin/sh /usr/local/bin/brew shellenv)"
else
    dotfiles_add_path /opt/homebrew/bin
    dotfiles_add_path /opt/homebrew/sbin
    dotfiles_add_path /usr/local/bin
    dotfiles_add_path /usr/local/sbin
fi
