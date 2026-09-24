# Install on a new machine

> **Scope:** this reference is for the **production / machine path** (deploying the dotfiles onto an installed machine via bare repo `$HOME/.cfg` and `dgit`). It is not about the dotfiles source repo — installing a source checkout is just `git clone` + `git checkout`.

Set up the dotfiles from scratch. Before you start, sync this skill to the latest so you have the most current install steps (if the runner is missing, obtain dependency-install consent first): `npx skills use YeSifan/dotfile@dotfile`.

Two things to keep in mind: the shell must be loadable before the tools are installed (every optional block is guarded by `command -v`), and the clone is a **bare** repo whose work-tree is `$HOME`.

## 0. Inspect dependencies and get consent

Read [dependency selection and consent](dependencies.md) before installing anything. Check the platform and existing tools first, then:

- List missing or incompatible required dependencies (Git, Zsh, Neovim >= 0.11, git-delta, and any needed NvChad setup prerequisites), their purpose, and the concrete installation/upgrade commands. Obtain the user's consent before running them.
- List applicable optional tools with their purpose and installed status, using the selection table in that reference. Let the user choose any subset or none; do not preselect all recommendations.
- Install only the approved dependencies and verify versions before deploying configuration that relies on them. Honor any explicit consent already given for the same plan. If required installation is declined, explain what cannot work and leave dependent setup pending.

An SSH key added to the GitHub account is also needed for the SSH clone below. Do not install a missing skills runner or package manager as an unapproved prerequisite.

## 1. Complete the approved dependency plan

Follow the choices made in step 0; this step is not permission to install additional packages. Required tools are Neovim >= 0.11 and git-delta, alongside Git and Zsh. Other tools are optional; selected tmux installations must be >= 3.5. `mise` remains recommended, not required or automatically activated.

For Debian / Ubuntu, a **required-only proposal to show the user before execution** is:

```zsh
sudo apt update
sudo apt install git zsh git-delta neovim
```

Check distribution versions before proposing this command. If they do not meet requirements, propose a compatible method from the [Neovim installation guide](https://github.com/neovim/neovim/blob/master/INSTALL.md) or [tmux installation guide](https://github.com/tmux/tmux/wiki/Installing). Adapt to the platform package manager; package examples are not authorization to run them.

Build a separate optional-package command from the user's actual selections. For example, choosing only ripgrep and jq means installing only those optional tools, not the entire recommendation list. Debian/Ubuntu calls the fd package `fd-find` and may expose it as `fdfind`; the environment check accepts either command.

For the approved NvChad setup, first launch downloads plugins. Use `:Lazy restore` to match the shared `~/.config/nvim/lazy-lock.json`; see [NvChad setup notes](packages/nvchad.md). Obtain consent for these downloads before launching Neovim as a verification step if they were not included in the original plan.

Fail2ban is offered only for applicable Linux SSH servers. Selecting package installation does not authorize enabling or reconfiguring the service; use the [server configuration notes](packages/fail2ban.md) within the user's chosen scope.

## 2. Clone the config

Proceed only after the required baseline dependencies have been approved, installed, and verified. If a required installation was declined, leave this dependent deployment pending.

```zsh
echo ".cfg" >> "$HOME/.gitignore"
git clone --bare git@github.com:Yesifan/dotfile.git "$HOME/.cfg"
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dgit checkout -f
dgit config --local status.showUntrackedFiles no
dgit fetch origin main:refs/remotes/origin/main
```

Notes:

- `.cfg` is added to `~/.gitignore` so the bare repo isn't treated as an untracked file in the user's own git repos.
- `dgit checkout -f` checks the tracked files out into `$HOME`. It is `-f` because the work-tree already contains real user files; warning about them is noise, not a reason to stop.
- `status.showUntrackedFiles no` keeps `dgit status` from listing the machine's untracked files (which by design are many).
- A bare clone may only have `FETCH_HEAD`, not a remote-tracking `origin/main`; the update/migration scripts reference `origin/main`, so the `fetch ... refs/remotes/origin/main` line above establishes it once.

## 3. Load the shell

Run this only after required dependencies are satisfied; skipped optional tools do not block shell startup.

```zsh
exec zsh -l
```

Or open a new terminal. Missing tools won't cause errors because the config guards every optional feature with `command -v`.

## 4. Set up environment variables

Only the variables the user needs belong here, and they go **inside a LOCAL block in `~/.zshrc`** (machine-local, never committed):

| Variable           | Needed for   | Purpose                   |
| ------------------ | ------------ | ------------------------- |
| `CONTEXT7_API_KEY` | Context7 MCP | Context7 API access       |
| `EXA_API_KEY`      | Exa MCP      | Exa web search API access |

See [agents.md](agents.md) for the full agent-side setup.

## 5. Verify

```zsh
exec zsh -l
```

The shell should start with no errors. Confirm the tracked files are present and the work-tree is clean:

```zsh
dgit status --short
dotfile-doctor
```

`dotfile-doctor` is defined in `~/.config/shell/doctor.zsh` and becomes available in a new shell. It checks `$HOME` by default; use `dotfile-doctor /path/to/dotfile` to check a source checkout. Required dependency or configuration errors return nonzero; missing optional tools do not fail the check. It never installs tools or edits files.

## 6. Install Agent Skills (optional)

The dotfile repo bundles the skills under `~/.agents/skills/` as part of the checkout. Additional global skills can be installed with:

```zsh
pnpm dlx skills add <package> -g
pnpm dlx skills update -g
```

See [agents.md](agents.md) for the skill list and tooling.
