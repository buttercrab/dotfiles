if command -sq starship
    starship init fish | source
end

if command -sq zoxide
    zoxide init fish | source
    alias cd=z
end

if command -sq fzf
    fzf --fish | source
end

if command -sq direnv
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
