# Login shell environment (sourced for login zsh). Shared login env goes here.
# Machine-specific login settings (e.g. brew shellenv) are added per machine,
# wrapped in a LOCAL block per the dotfile skill so they're preserved and
# never pushed.
export PATH="$HOME/.local/bin:$PATH"
