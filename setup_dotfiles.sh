#!/bin/bash

set +o errexit

DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO="git@github.com:threadproc/dotfiles.git"
DOTFILES_TMP="$HOME/df-tmp"

GITPATH=$(which git)

if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles already installed"
    exit 1
else
    echo "Installing dotfiles..."
    rm -rf "$DOTFILES_TMP" # cleanup after ourselves if this script previously failed
    
    # we want to get the submodules setup right away
    $GITPATH clone --separate-git-dir="$DOTFILES_DIR" "$DOTFILES_REPO" "$DOTFILES_TMP"
    cp "$DOTFILES_TMP/.gitmodules" "$HOME/.gitmodules"
    rm -rf "$DOTFILES_TMP"

    unalias dotfiles 2>/dev/null || true # in case this already exists from an unclean setup
    alias dotfiles="$GITPATH --git-dir=\"$DOTFILES_DIR\" --work-tree=\"$HOME\""
    dotfiles config status.showUntrackedFiles no
    dotfiles reset --hard
    dotfiles submodule init
    dotfiles submodule update

    echo "Dotfiles installed, please restart your shell"
fi