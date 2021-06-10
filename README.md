# Dotfiles

## Installation

### Font
Install the patched font - it's pretty good and has all the icons:
https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k

### Empty home directory
```
git clone --separate-git-dir=~/.dotfiles git@github.com:threadproc/dotfiles.git ~
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles submodule init
dotfiles submodule update
```
Then restart zsh

### Non-empty home directory

**NOTE**: this is untested still, but you get the idea. Clone into a temp dir, then pull again
with a different work tree.

```
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:threadproc/dotfiles.git $HOME/dotfiles-tmp
cp ~/dotfiles-tmp/.gitmodules ~
rm -r ~/dotfiles-tmp/
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles reset --hard
dotfiles submodule init
dotfiles submodule update
```
Then restart zsh
