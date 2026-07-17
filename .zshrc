# Thin interactive zsh entrypoint.
# Keep stable shared config in ~/.config/zsh/zshrc.

# =========remote config============
# This section is managed by the remote dotfiles repo.
# On dgit pull, conflicts here are resolved with remote (theirs).

[[ -r "$HOME/.config/zsh/zshrc" ]] && source "$HOME/.config/zsh/zshrc"

# =========remote end==============
# Everything below this line is machine-local. Do NOT commit.
