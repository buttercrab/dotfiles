#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

log() {
    printf '%s\n' "$*"
}

fail() {
    printf 'error %s\n' "$*" >&2
    exit 1
}

assert_file() {
    [ -e "$1" ] || fail "missing file: $1"
}

assert_contains() {
    file=$1
    pattern=$2
    grep -F "$pattern" "$file" >/dev/null 2>&1 || fail "expected '$pattern' in $file"
}

log "check shell syntax"
for file in \
    "$ROOT/bootstrap.sh" \
    "$ROOT/install.sh" \
    "$ROOT/bin/dotfiles-sync" \
    "$ROOT/bin/dotfiles-sync-enable" \
    "$ROOT/bin/dotfiles-sync-disable" \
    "$ROOT/bin/dotfiles-sync-status" \
    "$ROOT/bin/dotfiles-uninstall" \
    "$ROOT/bin/dotfiles-vendor-fish-update"
do
    sh -n "$file"
done

log "check fish syntax when fish is available"
if command -v fish >/dev/null 2>&1; then
    find "$ROOT/config/fish" -type f -name '*.fish' -print | while IFS= read -r file; do
        fish -n "$file"
    done
fi

tmp_home=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-validate.XXXXXX")
trap 'rm -rf "$tmp_home"' EXIT INT TERM HUP

log "bootstrap-only install into temp home"
mkdir -p "$tmp_home/dotfiles"
rsync -a --exclude .git "$ROOT/" "$tmp_home/dotfiles/"
chmod +x "$tmp_home/dotfiles/install.sh" "$tmp_home/dotfiles/bootstrap.sh" "$tmp_home/dotfiles/bin/"*

HOME="$tmp_home" DOTFILES_ROOT= DOTFILES_PROFILE_SOURCED= "$tmp_home/dotfiles/install.sh" >"$tmp_home/install.log" 2>&1
assert_file "$tmp_home/.config/dotfiles/install.env"
assert_contains "$tmp_home/install.log" "auto-sync not enabled"
assert_file "$tmp_home/.profile"
assert_file "$tmp_home/.config/fish/.dotfiles-vendor-manifest"

log "verify installed root is sourced from install env"
expected_root=$(CDPATH= cd -- "$tmp_home/dotfiles" && pwd)
shell_root_output=$(
    HOME="$tmp_home" DOTFILES_ROOT= DOTFILES_PROFILE_SOURCED= \
        sh -lc '. "$HOME/.profile"; printf "%s" "$DOTFILES_ROOT"'
)
case "$shell_root_output" in
    "$expected_root")
        ;;
    *)
        fail "unexpected DOTFILES_ROOT: $shell_root_output"
        ;;
esac

log "verify sync enable is blocked for fake HOME"
if HOME="$tmp_home" DOTFILES_ROOT= DOTFILES_PROFILE_SOURCED= "$tmp_home/dotfiles/install.sh" --enable-sync >"$tmp_home/enable.log" 2>&1; then
    fail "expected --enable-sync to fail for fake HOME"
fi
assert_contains "$tmp_home/enable.log" "requires the real home directory"

log "verify sync unlock path"
lock_dir="$tmp_home/lock"
mkdir -p "$lock_dir"
printf '999999\n' >"$lock_dir/pid"
printf '%s\n' "$(date +%s)" >"$lock_dir/started_at"
DOTFILES_SYNC_LOCK_DIR="$lock_dir" DOTFILES_SYNC_LOG_FILE="$tmp_home/sync.log" "$ROOT/bin/dotfiles-sync" --unlock >"$tmp_home/unlock.log" 2>&1
[ ! -d "$lock_dir" ] || fail "lock dir still exists after unlock"

log "validation complete"
