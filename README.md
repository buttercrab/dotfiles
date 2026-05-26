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
- Clone to `~/dotfiles`, then run `./bootstrap.sh`
- `bootstrap.sh` syncs vendored fish plugin files for offline startup; refresh plugins manually later with `fish -lc 'fisher update'`
