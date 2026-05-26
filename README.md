# dotfiles

Public, portable defaults for `~/dotfiles`.

## Layout

- `home/`: top-level files linked into `$HOME`
- `config/`: config linked into `$HOME/.config`
- `config/shell/profile.d/`: POSIX shell fragments
- `config/fish/conf.d/`: fish fragments
- `examples/local/`: private config examples

## Policy

- Secrets and machine-specific overrides live outside the repo under `~/.config/local/`
- Generated state does not belong in the repo
- Clone the repo, then run `./install.sh`
- `bootstrap.sh` syncs vendored fish plugin files for offline startup; refresh plugins manually later with `fish -lc 'fisher update'`

## Install

```sh
git clone git@github.com:buttercrab/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` bootstraps links and writes `~/.config/dotfiles/install.env` so shells know the installed repo root.

To enable background sync explicitly:

```sh
./install.sh --enable-sync
```

To disable background sync:

```sh
./install.sh --disable-sync
```

Helper commands:

```sh
~/dotfiles/bin/dotfiles-sync-enable
~/dotfiles/bin/dotfiles-sync-disable
~/dotfiles/bin/dotfiles-sync-status
~/dotfiles/bin/dotfiles-uninstall
```

## Auto Sync

Auto-sync is opt-in. When enabled, it runs on load and every 5 minutes by default.

Per run it will:

1. `git fetch origin main`
2. `git rebase origin/main`
3. rerun `bootstrap.sh` so pulled changes become live
4. auto-commit approved public-repo paths if they changed locally
5. `git push origin main`

Sync only stages repo-owned paths: `.gitignore`, `README.md`, `bootstrap.sh`, `install.sh`, `bin/`, `config/`, `home/`, `examples/`, and `vendor/`.

If rebase or push fails, it stops and retries on the next run. It never force-pushes. If a stale sync lock remains after a crash, run:

```sh
~/dotfiles/bin/dotfiles-sync --unlock
```

Private files under `~/.config/local` are not part of auto-sync.

## Notes

- macOS sync uses a user `LaunchAgent`, so it starts after user login.
- Linux sync uses `systemd --user`; reboot persistence depends on the user manager and, when available, linger.
- Background auto-commits are intentionally unsigned; keep personal identity and signing settings in `~/.config/local/git/config`.

## Fish Vendor Maintenance

Vendored fish plugin files under `vendor/fish/` are the offline source of truth.

To refresh them intentionally from the current local fish runtime:

```sh
~/dotfiles/bin/dotfiles-vendor-fish-update
```

The authoritative vendored file list lives in `vendor/fish/manifest.txt`.
