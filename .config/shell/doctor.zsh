# Read-only checks; sourcing this file only defines the command.
dotfile-doctor() (
  emulate -L zsh
  if [[ "$1" == --help ]]; then
    print -r -- 'Usage: dotfile-doctor [config-root]'
    print -r -- 'Check installed tools and dotfiles (default: $HOME). No changes are made.'
    return 0
  fi
  if (( $# > 1 )); then
    print -u2 -r -- 'Usage: dotfile-doctor [config-root]'
    return 2
  fi

  local config_root=${1:-$HOME}
  config_root=${config_root:A}
  local failures=0 warnings=0 tool file output version link expected
  local -a match mbegin mend
  autoload -Uz is-at-least

  _dotfile_ok() { print -r -- "OK    $*"; }
  _dotfile_fail() { print -r -- "FAIL  $*"; (( failures += 1 )); }
  _dotfile_warn() { print -r -- "WARN  $*"; (( warnings += 1 )); }

  print -r -- "Dotfile doctor — config root: $config_root"
  for tool in git zsh nvim delta; do
    if (( $+commands[$tool] )); then
      _dotfile_ok "$tool: $commands[$tool]"
    else
      _dotfile_fail "$tool: required command missing"
    fi
  done

  if (( $+commands[nvim] )); then
    output=$(command nvim --version 2>/dev/null)
    if [[ $output =~ 'NVIM v([0-9]+\.[0-9]+\.[0-9]+)' ]]; then
      version=$match[1]
      if is-at-least 0.11.0 "$version"; then
        _dotfile_ok "Neovim $version (requires >= 0.11)"
      else
        _dotfile_fail "Neovim $version: requires >= 0.11"
      fi
    else
      _dotfile_fail 'Neovim: could not determine version'
    fi
  fi

  if (( $+commands[tmux] )); then
    output=$(command tmux -V 2>/dev/null)
    if [[ $output =~ 'tmux ([0-9]+\.[0-9]+)' ]]; then
      version=$match[1]
      if is-at-least 3.5 "$version"; then
        _dotfile_ok "$output (requires >= 3.5 when installed)"
      else
        _dotfile_fail "$output: requires >= 3.5 for extended-keys-format csi-u"
      fi
    else
      _dotfile_fail 'tmux: could not determine version'
    fi
  else
    _dotfile_warn 'tmux: optional command missing'
  fi

  for tool in mise pnpm uv rg jq gh fzf zoxide starship; do
    if (( $+commands[$tool] )); then
      _dotfile_ok "$tool: $commands[$tool]"
    else
      _dotfile_warn "$tool: optional command missing"
    fi
  done
  if (( $+commands[fd] || $+commands[fdfind] )); then
    _dotfile_ok "fd: ${commands[fd]:-${commands[fdfind]}}"
  else
    _dotfile_warn 'fd/fdfind: optional command missing'
  fi

  for file in .zshenv .zshrc .config/shell/main.zsh .config/git/config \
    .config/nvim/init.lua .config/nvim/lua/clipboard.lua \
    .config/nvim/lazy-lock.json .tmux.conf .config/ghostty/config .codex/AGENTS.md; do
    if [[ -f "$config_root/$file" && -r "$config_root/$file" ]]; then
      _dotfile_ok "$file"
    else
      _dotfile_fail "$file: missing or unreadable"
    fi
  done

  expected=$config_root/.codex/AGENTS.md
  for file in .config/opencode/AGENTS.md .pi/agent/AGENTS.md; do
    link=$config_root/$file
    if [[ -L "$link" && -f "$link" && ${link:A} == ${expected:A} ]]; then
      _dotfile_ok "$file -> .codex/AGENTS.md"
    else
      _dotfile_fail "$file: must link to $expected"
    fi
  done

  for tool in EDITOR VISUAL; do
    if [[ ${(P)tool} == nvim || ${(P)tool} == */nvim ]]; then
      _dotfile_ok "$tool=${(P)tool}"
    else
      _dotfile_warn "$tool=${(P)tool:-<unset>}: expected nvim in the active shell"
    fi
  done
  print -r -- "Result: $failures failure(s), $warnings warning(s)."
  (( failures == 0 ))
)
