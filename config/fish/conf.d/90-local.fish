if test -d "$HOME/.config/local/env.d"
    for script in (command find "$HOME/.config/local/env.d" -maxdepth 1 -type f -name '*.fish' | sort)
        source "$script"
    end
end

if test -d "$HOME/.config/local/fish/conf.d"
    for script in (command find "$HOME/.config/local/fish/conf.d" -maxdepth 1 -type f -name '*.fish' | sort)
        source "$script"
    end
end
