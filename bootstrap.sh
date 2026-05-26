#!/bin/sh
set -eu

usage() {
    printf 'Usage: %s [--dry-run]\n' "$0" >&2
    exit 1
}

dry_run=0
case "${1-}" in
    "")
        ;;
    --dry-run)
        dry_run=1
        ;;
    *)
        usage
        ;;
esac

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BACKUP_ROOT="$HOME/.local/state/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
BACKUP_READY=0

log() {
    printf '%s\n' "$*"
}

warn() {
    printf 'warn  %s\n' "$*" >&2
}

set_mode() {
    mode_path=$1
    mode_value=$2

    if [ ! -e "$mode_path" ] && [ ! -L "$mode_path" ]; then
        return 0
    fi

    if [ "$dry_run" -eq 1 ]; then
        log "[dry-run] chmod $mode_value $mode_path"
    else
        chmod "$mode_value" "$mode_path"
    fi
}

ensure_backup_root() {
    if [ "$BACKUP_READY" -eq 1 ]; then
        return 0
    fi
    if [ "$dry_run" -eq 1 ]; then
        log "[dry-run] mkdir -p $BACKUP_ROOT"
    else
        mkdir -p "$BACKUP_ROOT"
    fi
    BACKUP_READY=1
}

backup_target() {
    backup_target_path=$1
    backup_target_rel=$2

    if [ ! -e "$backup_target_path" ] && [ ! -L "$backup_target_path" ]; then
        return 0
    fi

    ensure_backup_root
    backup_dest="$BACKUP_ROOT/$backup_target_rel"

    if [ "$dry_run" -eq 1 ]; then
        log "[dry-run] mkdir -p $(dirname "$backup_dest")"
        log "[dry-run] mv $backup_target_path $backup_dest"
        return 0
    fi

    mkdir -p "$(dirname "$backup_dest")"
    mv "$backup_target_path" "$backup_dest"
    log "backup $backup_target_path -> $backup_dest"
}

ensure_dir() {
    ensure_dir_path=$1
    ensure_dir_rel=$2

    if [ -d "$ensure_dir_path" ] && [ ! -L "$ensure_dir_path" ]; then
        return 0
    fi

    if [ -e "$ensure_dir_path" ] || [ -L "$ensure_dir_path" ]; then
        backup_target "$ensure_dir_path" "$ensure_dir_rel"
    fi

    if [ "$dry_run" -eq 1 ]; then
        log "[dry-run] mkdir -p $ensure_dir_path"
    else
        mkdir -p "$ensure_dir_path"
    fi
}

link_path() {
    link_src=$1
    link_dest=$2
    link_rel=$3
    link_parent=$(dirname "$link_dest")

    ensure_dir "$link_parent" ".dirs${link_parent#$HOME}"

    if [ -L "$link_dest" ]; then
        current=$(readlink "$link_dest" || true)
        if [ "$current" = "$link_src" ]; then
            log "ok    $link_dest"
            return 0
        fi
    fi

    if [ -e "$link_dest" ] || [ -L "$link_dest" ]; then
        backup_target "$link_dest" "$link_rel"
    fi

    if [ "$dry_run" -eq 1 ]; then
        log "[dry-run] ln -s $link_src $link_dest"
    else
        ln -s "$link_src" "$link_dest"
        log "link  $link_dest -> $link_src"
    fi
}

bootstrap_fish_plugins() {
    fish_vendor_root="$ROOT/vendor/fish"
    fish_manifest="$fish_vendor_root/manifest.txt"
    fish_target_root="$HOME/.config/fish"
    fish_state_manifest="$fish_target_root/.dotfiles-vendor-manifest"

    if [ ! -f "$fish_manifest" ]; then
        return 0
    fi

    if [ -f "$fish_state_manifest" ]; then
        old_ifs=$IFS
        IFS='
'
        for rel_path in $(cat "$fish_state_manifest"); do
            [ -n "$rel_path" ] || continue

            if grep -Fqx "$rel_path" "$fish_manifest"; then
                continue
            fi

            stale_target="$fish_target_root/$rel_path"
            if [ ! -e "$stale_target" ] && [ ! -L "$stale_target" ]; then
                continue
            fi

            if [ "$dry_run" -eq 1 ]; then
                log "[dry-run] rm -f $stale_target"
            else
                rm -f "$stale_target"
                log "prune $stale_target"
            fi
        done
        IFS=$old_ifs
    fi

    old_ifs=$IFS
    IFS='
'
    for rel_path in $(cat "$fish_manifest"); do
        [ -n "$rel_path" ] || continue

        sync_src="$fish_vendor_root/$rel_path"
        sync_dest="$fish_target_root/$rel_path"
        sync_parent=$(dirname "$sync_dest")

        ensure_dir "$sync_parent" ".dirs${sync_parent#$HOME}"

        if [ ! -e "$sync_src" ]; then
            warn "missing vendored fish file: $sync_src"
            continue
        fi

        if [ "$dry_run" -eq 1 ]; then
            log "[dry-run] cp $sync_src $sync_dest"
        else
            cp "$sync_src" "$sync_dest"
            log "sync  $sync_dest <- $sync_src"
        fi
    done
    IFS=$old_ifs

    if [ "$dry_run" -eq 1 ]; then
        log "[dry-run] cp $fish_manifest $fish_state_manifest"
    else
        cp "$fish_manifest" "$fish_state_manifest"
    fi
}

ensure_dir "$HOME/.config" ".dirs/.config"
ensure_dir "$HOME/.config/git" ".dirs/.config/git"
ensure_dir "$HOME/.config/fish" ".dirs/.config/fish"
ensure_dir "$HOME/.config/fish/conf.d" ".dirs/.config/fish/conf.d"
ensure_dir "$HOME/.config/fish/functions" ".dirs/.config/fish/functions"
ensure_dir "$HOME/.config/fish/completions" ".dirs/.config/fish/completions"
ensure_dir "$HOME/.config/local" ".dirs/.config/local"
ensure_dir "$HOME/.config/local/env.d" ".dirs/.config/local/env.d"
ensure_dir "$HOME/.config/local/fish/conf.d" ".dirs/.config/local/fish/conf.d"
ensure_dir "$HOME/.config/local/git" ".dirs/.config/local/git"
set_mode "$HOME/.config/local" 700
set_mode "$HOME/.config/local/env.d" 700
set_mode "$HOME/.config/local/fish" 700
set_mode "$HOME/.config/local/fish/conf.d" 700
set_mode "$HOME/.config/local/git" 700

link_path "$ROOT/home/.profile" "$HOME/.profile" ".profile"
link_path "$ROOT/home/.bash_profile" "$HOME/.bash_profile" ".bash_profile"
link_path "$ROOT/home/.bashrc" "$HOME/.bashrc" ".bashrc"
link_path "$ROOT/home/.zprofile" "$HOME/.zprofile" ".zprofile"
link_path "$ROOT/home/.zshrc" "$HOME/.zshrc" ".zshrc"
link_path "$ROOT/home/.gitconfig" "$HOME/.gitconfig" ".gitconfig"
link_path "$ROOT/home/.tmux.conf" "$HOME/.tmux.conf" ".tmux.conf"
link_path "$ROOT/config/starship.toml" "$HOME/.config/starship.toml" ".config/starship.toml"
link_path "$ROOT/config/git/config" "$HOME/.config/git/config" ".config/git/config"
link_path "$ROOT/config/nvim" "$HOME/.config/nvim" ".config/nvim"
link_path "$ROOT/config/fish/config.fish" "$HOME/.config/fish/config.fish" ".config/fish/config.fish"
link_path "$ROOT/config/fish/fish_plugins" "$HOME/.config/fish/fish_plugins" ".config/fish/fish_plugins"

for script in "$ROOT"/config/fish/conf.d/*.fish; do
    [ -e "$script" ] || continue
    name=$(basename "$script")
    link_path "$script" "$HOME/.config/fish/conf.d/$name" ".config/fish/conf.d/$name"
done

bootstrap_fish_plugins

if [ "$BACKUP_READY" -eq 1 ]; then
    log "backup root: $BACKUP_ROOT"
fi
