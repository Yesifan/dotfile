# Standard interactive zsh entrypoint — kept at ~/.zshrc (not $ZDOTDIR) so
# third-party installers that write to ~/.zshrc still work. Shared behavior
# lives in ~/.config/shell/. Add machine-local config below, wrapped in a
# LOCAL block per the dotfile skill so it's preserved on pull and never pushed.

for file in "$HOME"/.config/shell/*.zsh; do
  [[ -r "$file" ]] && source "$file"
done
