# Thin interactive zsh entrypoint.
# Keep stable shared config in ~/.config/zsh/zshrc. Tool installers may append
# machine-local setup below; avoid committing those generated blocks.

[[ -r "$HOME/.config/zsh/zshrc" ]] && source "$HOME/.config/zsh/zshrc"
[[ -r "$HOME/.config/zsh/zshrc.local" ]] && source "$HOME/.config/zsh/zshrc.local"
[[ -r "$HOME/.zshalias" ]] && source "$HOME/.zshalias"
