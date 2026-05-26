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
- Clone to `~/dotfiles`, then run `./install.sh`
- `bootstrap.sh` syncs vendored fish plugin files for offline startup; refresh plugins manually later with `fish -lc 'fisher update'`

## Install

```sh
git clone git@github.com:buttercrab/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` does two things:

- runs `./bootstrap.sh`
- installs an always-on auto-sync job for this user

## Auto Sync

The sync loop runs on load and every 5 minutes by default.

Per run it will:

1. auto-commit local public-repo changes if the repo is dirty
2. `git fetch origin main`
3. `git rebase origin/main`
4. `git push origin main`

If rebase or push fails, it stops and retries on the next run. It never force-pushes.

Private files under `~/.config/local` are not part of auto-sync.
