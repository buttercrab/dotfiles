if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx PATH "/home/jaeyong/.cargo/bin" $PATH
set -gx PATH "/home/linuxbrew/.linuxbrew/bin" $PATH
set -gx PATH $PATH "/home/jaeyong/.local/bin"
set -gx PATH $PATH "/usr/local/go/bin"
set -gx PATH $PATH "/home/jaeyong/go/bin"
# set -gx LC_CTYPE en_US.UTF-8
# set -gx LC_ALL en_US.UTF-8
# set -gx LANGUAGE en_US.UTF-8
# set -gx LANG en_US.UTF-8

function backup
    sudo cp -r /home/jaeyong /mnt/data/backup
end

function up
    for i in *
        if test -d $i
            cd $i
            docker-compose up -d 2> /dev/null || up
            cd ..
        end
    end
end

function init
    mkdir -p /mnt/data
    sudo mount /dev/md0 /mnt/data
    cd ~/docker-compose
    up
    cd ~
end

function down
    for i in *
        if test -d $i
            cd $i
            docker-compose down 2> /dev/null || down
            cd ..
        end
    end
end

function deinit
    cd ~/docker-compose
    down
    sudo umount /mnt/data
    cd ~
end

starship init fish | source

