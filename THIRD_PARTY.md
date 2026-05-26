# Third-Party Provenance

This repository contains both original project files and third-party material.

## Repository License

Unless otherwise noted, original files in this repository are licensed under the MIT license in the top-level `LICENSE` file.

## Included Third-Party Material

### `config/nvim/`

- Based on the [LazyVim starter template](https://github.com/LazyVim/starter)
- Upstream project license: Apache License 2.0
- The upstream license text is preserved in `config/nvim/LICENSE`

### `vendor/fish/completions/fisher.fish`
### `vendor/fish/functions/fisher.fish`

- Vendored from [jorgebucaran/fisher](https://github.com/jorgebucaran/fisher)
- Upstream project license: MIT
- Purpose here: offline fish bootstrap for installed machines

### `vendor/fish/completions/nvm.fish`
### `vendor/fish/conf.d/nvm.fish`
### `vendor/fish/functions/nvm.fish`
### `vendor/fish/functions/_nvm_*`

- Vendored from [jorgebucaran/nvm.fish](https://github.com/jorgebucaran/nvm.fish)
- Upstream project license: MIT
- Purpose here: offline fish bootstrap for installed machines

## Maintenance Notes

- `vendor/fish/manifest.txt` is the authoritative vendored file list.
- `bin/dotfiles-vendor-fish-update` refreshes vendored fish files intentionally from a local fish runtime.
- When updating vendored content, preserve upstream license notices and update this document if provenance changes.
