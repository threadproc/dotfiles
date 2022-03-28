#!/bin/bash

set -o errexit

install_package() {
    pkg="$1"
    if [ -z "$pkg" ]; then
        echo "package name can't be empty"
        exit 1
    fi

    echo "Installing package $pkg"

    if [ $(uname) == "Darwin" ]; then
        brew install "$pkg" > /dev/null 2>&1
    elif [ $(uname) == "Linux" ]; then

        if [ `command -v apt-get` ]; then
            # this is a debian-based distro
            DEBIAN_FRONTEND=noninteractive apt-get -y install "$pkg" > /dev/null 2>&1
        elif [ `command -v yum` ]; then
            # centos, RHEL, etc
            yum -y install "$pkg" > /dev/null 2>&1
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

DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO="https://github.com/threadproc/dotfiles.git"
DOTFILES_TMP="$HOME/df-tmp"
OS=$(uname)

# attempt to install git if it isn't already installed
install_if_missing "git"
GITPATH=$(which git)
DFEXEC="$GITPATH --git-dir=$DOTFILES_DIR --work-tree=$HOME"

if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles already installed, updating"
    exec $DFEXEC pull > /dev/null
else
    echo "Installing dotfiles..."
fi

rm -rf "$DOTFILES_TMP" # cleanup after ourselves if this script previously failed

# check for zsh
install_if_missing "zsh"

# we want to get the submodules setup right away
echo "Cloning dotfiles repository..."
$GITPATH clone --separate-git-dir="$DOTFILES_DIR" "$DOTFILES_REPO" "$DOTFILES_TMP" > /dev/null 2>&1
cp "$DOTFILES_TMP/.gitmodules" "$HOME/.gitmodules"
rm -rf "$DOTFILES_TMP"

cd "$HOME"
echo "Configuring dotfiles and submodules..."
$DFEXEC config status.showUntrackedFiles no > /dev/null
$DFEXEC reset --hard > /dev/null
$DFEXEC submodule init > /dev/null
$DFEXEC submodule update > /dev/null

if [ "$SHELL" != `which zsh` ]; then
    echo "Changing default shell, you may be prompted for your password"

    # we try to use sudo where we can since some environments are setup to do passwordless sudo
    # (docker, Google Cloud Shell, etc)
    if [ `command -v sudo` ]; then
        sudo chsh -s `which zsh` `whoami`
    else
        chsh -s `which zsh`
    fi
else
    echo "Default shell is already zsh"
fi

echo "Dotfiles installed, please restart your shell"