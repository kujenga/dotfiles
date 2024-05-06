#!/bin/bash
#
# This script installs configuration onto the current machine.

set -euxo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Install Homebrew
# https://brew.sh/
if [[ $(command -v brew) == "" ]]; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install oh-my-zsh
# https://ohmyz.sh/#install
if [ ! -e ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Rust
if [[ $(command -v rustup) == "" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# Platform specific setup
case $(uname) in
Darwin)
    # Install Homebrew: https://github.com/Homebrew/install
    type brew >/dev/null 2>&1 || { echo >&2 "I require Homebrew but it's not installed.  Aborting."; exit 1; }

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

    # Install homebrew on linux
    # https://docs.brew.sh/Homebrew-on-Linux
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc

    ;;
esac

# Install the brew bundle for my preferences.
brew bundle --file="$DIR/Brewfile"

# Sync configuration files
$DIR/sync.sh -o

# Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install vim dependencies.
vim -c 'PlugInstall | qa'
