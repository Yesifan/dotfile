# Cross-platform zsh configuration.

# Dotfiles bare repository helper.
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Machine-local aliases. This file is intentionally not tracked.
[[ -f "$HOME/.zshalias" ]] && source "$HOME/.zshalias"

# zoxide: smarter directory jumping.
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# fzf: fuzzy finder shell integration for real terminal sessions.
if command -v fzf >/dev/null 2>&1 && [[ -t 0 ]]; then
  source <(fzf --zsh)
fi

# starship: prompt.
if command -v starship >/dev/null 2>&1 && [[ "${TERM:-}" != dumb ]]; then
  eval "$(starship init zsh)"
fi

# Node Version Manager.
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# pnpm.
case "$(uname -s)" in
  Darwin)
    PNPM_HOME="$HOME/Library/pnpm"
    ;;
  Linux)
    PNPM_HOME="$HOME/.local/share/pnpm"
    ;;
esac

if [[ -n "$PNPM_HOME" && -d "$PNPM_HOME" ]]; then
  export PNPM_HOME
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
fi
