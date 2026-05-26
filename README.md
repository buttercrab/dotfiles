# dotfiles

Public, portable defaults for `~/dotfiles`.

## Supported Platforms

- macOS with a user login session
- Linux with a writable home directory

Auto-sync support is platform-specific:

- macOS: user `launchd` `LaunchAgent`
- Linux: `systemd --user` timer, with reboot persistence depending on the user manager and, when available, linger

## Prerequisites

- `git`
- `rsync`
- SSH access to your Git remote if you enable auto-sync
- For Linux auto-sync: a working `systemd --user` session

Optional but assumed by parts of the repo:

- `fish`
- `nvim`
- `tmux`

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

What bootstrap touches:

- `~/.profile`
- `~/.bash_profile`
- `~/.bashrc`
- `~/.zprofile`
- `~/.zshrc`
- `~/.gitconfig`
- `~/.tmux.conf`
- `~/.config/starship.toml`
- `~/.config/git/config`
- `~/.config/nvim`
- `~/.config/fish/config.fish`
- `~/.config/fish/fish_plugins`
- tracked fish `conf.d/*.fish`

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

## Backups

Bootstrap moves replaced files into timestamped backups under:

- `~/.local/state/dotfiles-backups/`

Migration-only backups created during this rollout may also exist beside the repo, but the bootstrap contract is the directory above.

## Recovery

Inspect sync state:

```sh
~/dotfiles/bin/dotfiles-sync-status
```

Clear a dead sync lock:

```sh
~/dotfiles/bin/dotfiles-sync --unlock
```

If auto-sync hits a rebase or stash-restore conflict, resolve it manually inside `~/dotfiles`, then rerun:

```sh
~/dotfiles/bin/dotfiles-sync
```

## Uninstall

Disable background sync only:

```sh
~/dotfiles/bin/dotfiles-uninstall
```

Disable sync and remove bootstrapped links plus vendored fish files:

```sh
~/dotfiles/bin/dotfiles-uninstall --purge-links
```

Backups are not deleted automatically.

## Fish Vendor Maintenance

Vendored fish plugin files under `vendor/fish/` are the offline source of truth.

To refresh them intentionally from the current local fish runtime:

```sh
~/dotfiles/bin/dotfiles-vendor-fish-update
```

The authoritative vendored file list lives in `vendor/fish/manifest.txt`.

## Validation

Local validation:

```sh
sh ./scripts/validate.sh
```

CI runs the same validation script on:

- `ubuntu-latest`
- `macos-latest`

## Provenance

- Repository license: `LICENSE`
- Third-party provenance and exceptions: `THIRD_PARTY.md`
