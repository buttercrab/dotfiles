if status is-interactive
    # Commands to run in interactive sessions can go here
end

switch (uname)
    case Linux
        set -gx PATH "/home/linuxbrew/.linuxbrew/bin" $PATH
        set -gx PATH $PATH "$HOME/go/bin"
    case Darwin
        set -gx PATH /opt/homebrew/bin $PATH
        set -gx PATH $PATH /usr/local/go/bin
end

set -gx PATH "$HOME/.cargo/bin" $PATH
set -gx PATH $PATH "$HOME/.local/bin"
set -Ux PYENV_ROOT "$HOME/.pyenv"
set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths
set -gx EDITOR nvim
set -gx LC_CTYPE en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx LANGUAGE en_US.UTF-8
set -gx LANG en_US.UTF-8
set -gx RUSTFLAGS "-Z threads=12"

function echo-yellow
    echo "$(set_color yellow)>> $argv$(set_color normal)"
end

function do-backup
    sudo cp -r /home/jaeyong /mnt/data/backup
end

function docker-up
    for i in (ls)
        if test -d $i
            cd $i
            if test -f docker-compose.yaml || test -f docker-compose.yml
                echo-yellow "up $i"
                docker compose pull >/tmp/docker-pull-$i.log 2>&1 || cat /tmp/docker-pull-$i.log
                docker compose up -d >/tmp/docker-up-$i.log 2>&1 || cat /tmp/docker-up-$i.log
            else if test -f docker-compose.yaml.inactive || test -f docker-compose.yml.inactive
                echo-yellow "skip $i"
            else
                docker-up
            end
            cd ..
        end
    end
end

function docker-init
    echo-yellow "mount /dev/md0 to /mnt/data"
    mkdir -p /mnt/data
    sudo mount /dev/md0 /mnt/data
    cd ~/docker-compose
    docker-up
    cd ~
end

function docker-down
    for i in (ls)
        if test -d $i
            cd $i
            if test -f docker-compose.yaml || test -f docker-compose.yml
                echo-yellow "down $i"
                docker compose down >/tmp/docker-down-$i.log 2>&1 || cat /tmp/docker-down-$i.log
            else if test -f docker-compose.yaml.inactive || test -f docker-compose.yml.inactive
                echo-yellow "skip $i"
            else
                docker-down
            end
            cd ..
        end
    end
end

function docker-deinit
    cd ~/docker-compose
    docker-down
    echo-yellow "umount /mnt/data"
    sudo umount /mnt/data
    cd ~
end

starship init fish | source
pyenv init - | source
zoxide init fish | source
fzf --fish | source

alias cd=z
alias vim=nvim
alias ls=eza
