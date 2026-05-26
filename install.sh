#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SYNC_INTERVAL=${DOTFILES_SYNC_INTERVAL:-300}
SERVICE_NAME=${DOTFILES_SYNC_SERVICE_NAME:-com.buttercrab.dotfiles-sync}
STATE_DIR="$HOME/.config/dotfiles"
INSTALL_ENV="$STATE_DIR/install.env"
ENABLE_SYNC=0
DISABLE_SYNC=0
FORCE_INSTALL=0

usage() {
    cat <<'EOF' >&2
Usage: ./install.sh [--enable-sync] [--disable-sync] [--force]
EOF
    exit 1
}

log() {
    printf '%s\n' "$*"
}

warn() {
    printf 'warn  %s\n' "$*" >&2
}

while [ $# -gt 0 ]; do
    case "$1" in
        --enable-sync)
            ENABLE_SYNC=1
            ;;
        --disable-sync)
            DISABLE_SYNC=1
            ;;
        --force)
            FORCE_INSTALL=1
            ;;
        *)
            usage
            ;;
    esac
    shift
done

if [ "$ENABLE_SYNC" -eq 1 ] && [ "$DISABLE_SYNC" -eq 1 ]; then
    usage
fi

ensure_state_dir() {
    mkdir -p "$STATE_DIR"
    chmod 700 "$STATE_DIR"
}

load_installed_root() {
    installed_root=
    if [ -r "$INSTALL_ENV" ]; then
        installed_root=$(
            DOTFILES_ROOT=
            # shellcheck disable=SC1090
            . "$INSTALL_ENV"
            printf '%s\n' "${DOTFILES_ROOT:-}"
        )
    fi
    printf '%s\n' "$installed_root"
}

write_install_env() {
    ensure_state_dir
    cat >"$INSTALL_ENV" <<EOF
DOTFILES_ROOT='$ROOT'
DOTFILES_SYNC_INTERVAL='$SYNC_INTERVAL'
DOTFILES_SYNC_SERVICE_NAME='$SERVICE_NAME'
EOF
    chmod 600 "$INSTALL_ENV"
}

guard_root_replacement() {
    installed_root=$(load_installed_root)
    if [ -n "$installed_root" ] && [ "$installed_root" != "$ROOT" ] && [ "$FORCE_INSTALL" -ne 1 ]; then
        printf 'error current install root is %s, refusing to replace it with %s without --force\n' "$installed_root" "$ROOT" >&2
        exit 1
    fi
}

guard_real_home_for_sync() {
    case "$(uname -s)" in
        Darwin|Linux)
            real_home=$(eval "printf '%s' ~$USER")
            ;;
        *)
            return 0
            ;;
    esac

    if [ "$HOME" != "$real_home" ] && [ "$FORCE_INSTALL" -ne 1 ]; then
        printf 'error sync install requires the real home directory (%s), got HOME=%s; rerun without overriding HOME or pass --force\n' "$real_home" "$HOME" >&2
        exit 1
    fi
}

install_macos_sync() {
    launch_agents_dir="$HOME/Library/LaunchAgents"
    plist_path="$launch_agents_dir/$SERVICE_NAME.plist"
    log_dir="$HOME/.local/state"

    mkdir -p "$launch_agents_dir" "$log_dir"

    cat >"$plist_path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$SERVICE_NAME</string>
  <key>ProgramArguments</key>
  <array>
    <string>$ROOT/bin/dotfiles-sync</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>$SYNC_INTERVAL</integer>
  <key>StandardOutPath</key>
  <string>$log_dir/dotfiles-sync.log</string>
  <key>StandardErrorPath</key>
  <string>$log_dir/dotfiles-sync.log</string>
  <key>WorkingDirectory</key>
  <string>$ROOT</string>
</dict>
</plist>
EOF

    launchctl bootout "gui/$(id -u)" "$plist_path" >/dev/null 2>&1 || true
    launchctl bootstrap "gui/$(id -u)" "$plist_path"
    launchctl kickstart -k "gui/$(id -u)/$SERVICE_NAME" >/dev/null 2>&1 || true

    log "installed macOS LaunchAgent at $plist_path"
}

disable_macos_sync() {
    launch_agents_dir="$HOME/Library/LaunchAgents"
    plist_path="$launch_agents_dir/$SERVICE_NAME.plist"

    launchctl bootout "gui/$(id -u)" "$plist_path" >/dev/null 2>&1 || true
    rm -f "$plist_path"
    log "disabled macOS LaunchAgent at $plist_path"
}

install_linux_sync() {
    systemd_dir="$HOME/.config/systemd/user"
    service_path="$systemd_dir/dotfiles-sync.service"
    timer_path="$systemd_dir/dotfiles-sync.timer"

    mkdir -p "$systemd_dir"

    cat >"$service_path" <<EOF
[Unit]
Description=Sync dotfiles repository

[Service]
Type=oneshot
WorkingDirectory=$ROOT
ExecStart=$ROOT/bin/dotfiles-sync
EOF

    cat >"$timer_path" <<EOF
[Unit]
Description=Run dotfiles sync periodically

[Timer]
OnBootSec=2m
OnUnitActiveSec=${SYNC_INTERVAL}s
RandomizedDelaySec=30s
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable --now dotfiles-sync.timer

    if command -v loginctl >/dev/null 2>&1; then
        loginctl enable-linger "$USER" >/dev/null 2>&1 || warn "could not enable linger; timer may wait until login after reboot"
    fi

    log "installed systemd user timer at $timer_path"
}

disable_linux_sync() {
    systemd_dir="$HOME/.config/systemd/user"
    service_path="$systemd_dir/dotfiles-sync.service"
    timer_path="$systemd_dir/dotfiles-sync.timer"

    systemctl --user disable --now dotfiles-sync.timer >/dev/null 2>&1 || true
    rm -f "$service_path" "$timer_path"
    systemctl --user daemon-reload
    systemctl --user reset-failed dotfiles-sync.service dotfiles-sync.timer >/dev/null 2>&1 || true
    log "disabled systemd user timer at $timer_path"
}

chmod +x "$ROOT/bootstrap.sh" "$ROOT/bin/dotfiles-sync"
guard_root_replacement
write_install_env
"$ROOT/bootstrap.sh"

case "$(uname -s)" in
    Darwin)
        if [ "$ENABLE_SYNC" -eq 1 ]; then
            guard_real_home_for_sync
            install_macos_sync
        fi
        if [ "$DISABLE_SYNC" -eq 1 ]; then
            guard_real_home_for_sync
            disable_macos_sync
        fi
        ;;
    Linux)
        if [ "$ENABLE_SYNC" -eq 1 ]; then
            guard_real_home_for_sync
            install_linux_sync
        fi
        if [ "$DISABLE_SYNC" -eq 1 ]; then
            guard_real_home_for_sync
            disable_linux_sync
        fi
        ;;
    *)
        warn "unsupported OS for auto-sync install: $(uname -s)"
        ;;
esac

log "bootstrap complete"
if [ "$ENABLE_SYNC" -eq 1 ]; then
    log "auto-sync enabled"
    log "sync interval: ${SYNC_INTERVAL}s"
    log "sync log: $HOME/.local/state/dotfiles-sync.log"
elif [ "$DISABLE_SYNC" -eq 1 ]; then
    log "auto-sync disabled"
else
    log "auto-sync not enabled; rerun with --enable-sync to install background sync"
fi
