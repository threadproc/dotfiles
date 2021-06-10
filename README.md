# Dotfiles

## Installation

### Empty home directory
```
git clone --separate-git-dir=~/.dotfiles git@github.com:threadproc/dotfiles.git ~
```
Then restart zsh

### Non-empty home directory

**NOTE**: this is untested still, but you get the idea. Clone into a temp dir, then pull again
with a different work tree.

```
git clone --separate-git-dir=~/.dotfiles git@github.com:threadproc/dotfiles.git ~/dotfiles-tmp
cp ~/dotfiles-tmp/.gitmodules ~
rm -r ~/dotfiles-tmp/
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles pull origin master
```
Then restart zsh
