#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SYNC_INTERVAL=${DOTFILES_SYNC_INTERVAL:-300}
SERVICE_NAME=${DOTFILES_SYNC_SERVICE_NAME:-com.buttercrab.dotfiles-sync}

log() {
    printf '%s\n' "$*"
}

warn() {
    printf 'warn  %s\n' "$*" >&2
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
WorkingDirectory=%h/dotfiles
ExecStart=%h/dotfiles/bin/dotfiles-sync
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

chmod +x "$ROOT/bootstrap.sh" "$ROOT/bin/dotfiles-sync"
"$ROOT/bootstrap.sh"

case "$(uname -s)" in
    Darwin)
        install_macos_sync
        ;;
    Linux)
        install_linux_sync
        ;;
    *)
        warn "unsupported OS for auto-sync install: $(uname -s)"
        ;;
esac

log "bootstrap complete"
log "sync interval: ${SYNC_INTERVAL}s"
log "sync log: $HOME/.local/state/dotfiles-sync.log"
