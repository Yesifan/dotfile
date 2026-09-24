# Dependency selection and consent

Apply this workflow to both initial machine setup and updates. A request to install or update dotfiles does **not** by itself authorize installing or upgrading dependencies. “Required” describes what the configuration needs, not permission to install it.

## Before changing dependencies

1. Inspect the platform, available commands, and installed versions without modifying the machine. Use `dotfile-doctor` if available; otherwise check the commands directly. Already compatible dependencies need no installation.
2. Present missing or incompatible **required** dependencies, their purpose, the needed version, and the proposed package-manager commands. Ask whether the user agrees to that installation or upgrade, and wait for an answer before running it.
3. Present applicable **optional** dependencies with their purpose and current installation status. Ask the user to choose which to install, including the option to choose none. Do not bundle unselected optional tools into a required-dependency install command.
4. Execute only the approved plan, then verify the installed commands and versions. The plan may include normal package-manager dependencies; do not ask separately for every transitive package. If the plan needs another tool, a different install method, or an additional upgrade outside the approved scope, explain the change and obtain consent for it first.

Existing explicit consent for the same dependency changes remains valid; do not ask again. Silence, a timeout, a tool being listed as recommended, or a generic “update everything” in the dotfiles context is not a selection of optional dependencies. On updates, offer newly relevant or missing optional tools rather than reinstalling or upgrading all recommendations.

If a required dependency is declined, explain the affected workflow and leave its installation pending. Continue independent authorized work, but do not activate changes that need the missing tool or report the environment as ready. Declined optional dependencies are simply skipped.

These rules also cover prerequisites for skill synchronization: if Node.js, pnpm, or another runner is missing, do not bootstrap it just to run a skills command without consent. Launching Neovim for the first time can install lazy.nvim and NvChad plugins; disclose and include those downloads in the approved editor setup before using startup as a verification step. Installing a server package does not by itself authorize changing its service or firewall configuration.

## Required baseline

| Dependency | Purpose / requirement |
| --- | --- |
| Git | Clone and update the dotfiles repository; provide `dgit`. |
| Zsh | Run the managed shell configuration. |
| Neovim >= 0.11 | Default `EDITOR` / `VISUAL` and the bundled NvChad configuration. |
| git-delta (`delta`) | Git paging and interactive diff filtering. |

For NvChad, also explain the plugin downloads and any missing setup prerequisites from [nvchad.md](packages/nvchad.md), including a compiler, make, tree-sitter CLI, and a Nerd Font on the terminal machine. Include necessary installation in the approval request rather than silently adding it later.

## Optional choices

Present the tools relevant to the target machine; this is a selection menu, not an installation command.

| Tool | Purpose / where useful |
| --- | --- |
| Starship | Shell prompt showing directory and development context. |
| zoxide | Jump to frequently used directories. |
| fzf | Interactive fuzzy selection and shell history search. |
| zsh-autosuggestions | Suggest commands from shell history. |
| zsh-syntax-highlighting | Highlight command-line syntax. |
| tmux >= 3.5 | Persistent terminal sessions, windows, and panes; installed versions must support the shipped configuration. |
| ripgrep (`rg`) | Search file contents. |
| fd (`fdfind` on some distributions) | Find files and directories. |
| jq | Query and transform JSON. |
| GitHub CLI (`gh`) | Work with GitHub repositories, pull requests, and issues. |
| Ghostty | Local graphical terminal; normally installed on the connecting machine, not a headless SSH server. |
| Vim | Alternative editor; its existing config is retained, but it does not satisfy the Neovim requirement. |
| mise | Manage development tools and runtime versions; recommended, never required solely by preference. |
| pnpm | Manage JavaScript / TypeScript packages. |
| uv | Manage Python environments, dependencies, and tools. |
| Fail2ban | Optional Linux SSH server protection; see [server configuration](packages/fail2ban.md). |

If a selected optional tool needs additional prerequisites, include them in its installation plan. Prefer the user's package-management choices where applicable, respect existing project tooling, and use the distribution package manager for system services such as Fail2ban.
