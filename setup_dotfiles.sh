#!/bin/bash

set -o errexit

DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO="https://github.com/threadproc/dotfiles.git"
DOTFILES_TMP="$HOME/df-tmp"
OS=$(uname)

if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles already installed"
    exit 1
fi

install_package() {
    pkg="$1"
    if [ -z "$pkg" ]; then
        echo "package name can't be empty"
        exit 1
    fi

    echo "Installing package $pkg"

    if [ $(uname) == "Darwin" ]; then
        brew install "$pkg"
    elif [ $(uname) == "Linux" ]; then

        if [ `command -v apt-get` ]; then
            # this is a debian-based distro
            DEBIAN_FRONTEND=noninteractive apt-get -y install "$pkg"
        elif [ `command -v yum` ]; then
            # centos, RHEL, etc
            yum -y install "$pkg"
        else
            echo "no supported package manager found"
            exit 1
        fi

    else
        echo "unsupported platform: $(uname)"
        exit 1
    fi
}

install_if_missing() {
    cmd="$1"
    pkg="$2"

    if [ -z "$pkg" ]; then
        pkg="$cmd"
    fi

    if [ ! `command -v "$cmd"` ]; then install_package "$pkg"; fi
}

# attempt to install git if it isn't already installed
install_if_missing "git"
GITPATH=$(which git)

echo "Installing dotfiles..."
rm -rf "$DOTFILES_TMP" # cleanup after ourselves if this script previously failed

# check for zsh
install_if_missing "zsh"

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