# Shared fish setup is split across conf.d/*.fish.
# Private overrides live outside the repo under ~/.config/local.

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
