# shellcheck shell=sh

if [ -n "${DOTFILES_PROFILE_SOURCED:-}" ]; then
    return 0
fi

if [ -r "$HOME/.config/dotfiles/install.env" ]; then
    . "$HOME/.config/dotfiles/install.env"
fi

export DOTFILES_PROFILE_SOURCED=1
export DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/dotfiles}"

dotfiles_add_path() {
    [ $# -eq 1 ] || return 0
    [ -d "$1" ] || return 0
    case ":$PATH:" in
        *":$1:"*)
            ;;
        *)
            PATH="$1${PATH:+:$PATH}"
            ;;
    esac
}

for script in "$DOTFILES_ROOT"/config/shell/profile.d/*.sh; do
    [ -r "$script" ] || continue
    . "$script"
done

export PATH
