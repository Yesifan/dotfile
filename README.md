# [STORE THE DOTFILE](https://www.atlassian.com/git/tutorials/dotfiles?utm_source=pocket_reader)

Disclaimer: the title is slightly hyperbolic, there are other proven solutions to the problem. I do think the technique below is very elegant though.

Recently I read about this amazing technique in an Hacker News thread on people's solutions to store their dotfiles. User StreakyCobra showed his elegant setup and ... It made so much sense! I am in the process of switching my own system to the same technique. The only pre-requisite is to install Git.

In his words the technique below requires:

No extra tooling, no symlinks, files are tracked on a version control system, you can use different branches for different computers, you can replicate you configuration easily on new installation.

The technique consists in storing a Git bare repository in a "side" folder (like $HOME/.cfg or $HOME/.myconfig) using a specially crafted alias so that commands are run against that repository and not the usual .git local folder, which would interfere with any other Git repositories around.

## Starting from scratch
If you haven't been tracking your configurations in a Git repository before, you can start using this technique easily with these lines:

```bash
git init --bare $HOME/.cfg
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dgit config --local status.showUntrackedFiles no
echo "alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bashrc
```


```bash
dgit status
dgit add .vimrc
dgit commit -m "Add vimrc"
dgit add .bashrc
dgit commit -m "Add bashrc"
dgit push
```

## Installing your dotfiles onto a new system (or migrate to this setup)

First install `zsh` and `oh-my-zsh`, install plugin `zsh-autosuggestions` and `zsh-syntax-highlighting`.

Then clone your dotfiles into a bare repository on a new system using the technique above. And then checkout the actual content from the bare repository to your $HOME:

```bash
echo ".cfg" >> .gitignore
git clone --bare git@github.com:Yesifan/dotfile.git $HOME/.cfg
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dgit checkout -f
```

### For vim
[The Ultimate vimrc](https://github.com/amix/vimrc)
