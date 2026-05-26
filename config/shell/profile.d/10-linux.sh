case "$(uname -s)" in
    Linux)
        ;;
    *)
        return 0
        ;;
esac

if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(SHELL=/bin/sh /home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    dotfiles_add_path /home/linuxbrew/.linuxbrew/bin
    dotfiles_add_path /home/linuxbrew/.linuxbrew/sbin
fi
