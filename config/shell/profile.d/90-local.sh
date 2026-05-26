local_env_dir="$HOME/.config/local/env.d"

if [ -d "$local_env_dir" ]; then
    old_ifs=$IFS
    IFS='
'
    for script in $(find "$local_env_dir" -maxdepth 1 -type f -name '*.sh' -print | LC_ALL=C sort); do
        [ -r "$script" ] || continue
        . "$script"
    done
    IFS=$old_ifs
fi
