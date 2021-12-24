#!/bin/bash
#
# This script installs configuration onto the current machine.

set -euxo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Install Rust
if ! which rustup 2>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Configure git
git config --global alias.st "status"
git config --global alias.br "branch"
git config --global alias.co "checkout"
git config --global alias.fpush "push --force-with-lease"
git config --global alias.last "log -1 HEAD"
git config --global alias.recent "log --pretty=medium --stat -5 HEAD"
git config --global alias.hist "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
# https://stackoverflow.com/a/31687960
git config --global alias.sl "stash list --format='%gd (%cr): %gs'"
# https://stackoverflow.com/a/5188364
git config --global alias.bl "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:short)%(color:reset))'"
# from @jessfraz https://github.com/jessfraz/dotfiles/blob/master/.gitconfig
git config --global alias.dm "\!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d; git remote -v update -p"
# allow "go get" to fetch private repos with ssh keys
# https://gist.github.com/shurcooL/6927554
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Platform specific setup
case $(uname) in
Darwin)
    # Install Homebrew: https://github.com/Homebrew/install
    type brew >/dev/null 2>&1 || { echo >&2 "I require Homebrew but it's not installed.  Aborting."; exit 1; }

    # Install the brew bundle for my application.
    brew bundle --file="$DIR/macos/Brewfile"

    # NOTE: This is currently disabled because it does not seem to be needed on
    # the latest macs for most use cases, but kept around for reference if
    # needed in the future.
    #
    # Based on: https://wilsonmar.github.io/maximum-limits/ except we only
    # configure mac files, since max proc defaults seem reasonable.
    # echo 'Configuring file limits'
    # sudo cp "$DIR/macos/limit.maxfiles.plist" "/Library/LaunchDaemons/limit.maxfiles.plist"
    # sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist

    ;;

Linux)
    type apt-get >/dev/null 2>&1 || { echo >&2 "I require apt-get but it's not installed.  Aborting."; exit 1; }

    sudo apt-get install -y \
        tree \
        jq \
        build-essential \
        python3-dev

    ;;
esac
