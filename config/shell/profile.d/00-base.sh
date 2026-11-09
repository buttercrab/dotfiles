dotfiles_add_path "$HOME/.local/bin"
dotfiles_add_path "$HOME/.cargo/bin"
dotfiles_add_path "$HOME/go/bin"

export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
dotfiles_add_path "$BUN_INSTALL/bin"

if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    dotfiles_add_path "$PYENV_ROOT/bin"
fi

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

dotfiles_rustc_is_nightly() {
    command -v rustc >/dev/null 2>&1 || return 1
    rustc -vV 2>/dev/null | grep -Eq '^release: .*nightly'
}

# Disabled (matches fish 00-base.fish): the check runs in $HOME where the default
# toolchain is nightly, but repos pinned to stable via rust-toolchain.toml then fail
# with "the option `Z` is only accepted on the nightly compiler". A RUSTFLAGS env var
# also silently overrides every build.rustflags / target.*.rustflags in cargo config.
# if [ -z "${RUSTFLAGS+x}" ] && dotfiles_rustc_is_nightly; then
#     export RUSTFLAGS="-Z threads=12"
# fi

dotfiles_pick_locale() {
    command -v locale >/dev/null 2>&1 || return 1
    for candidate in "$@"; do
        [ -n "$candidate" ] || continue
        if locale -a 2>/dev/null | grep -Fxi -- "$candidate" >/dev/null 2>&1; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

dotfiles_locale="${LC_ALL:-${LANG:-}}"
if ! dotfiles_pick_locale "$dotfiles_locale" >/dev/null 2>&1; then
    dotfiles_locale="$(dotfiles_pick_locale en_US.UTF-8 en_US.utf8 C.UTF-8)"
fi

if [ -n "${dotfiles_locale:-}" ]; then
    export LANG="$dotfiles_locale"
    export LC_CTYPE="$dotfiles_locale"
    export LC_ALL="$dotfiles_locale"
    export LANGUAGE="$dotfiles_locale"
fi

unset dotfiles_locale
