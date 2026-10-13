#!/bin/bash
#
# This script installs configuration onto the current machine.

set -exo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


# Function definitions

# Homebrew for macos
# https://brew.sh/
install_brew() {
    if [[ $(command -v brew) == "" ]]; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "brew already installed: $(which brew)"
    fi
}

# Homebrew on linux
# https://docs.brew.sh/Homebrew-on-Linux
install_linuxbrew() {
    install_brew
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc
}

# oh-my-zsh
# https://ohmyz.sh/#install
install_oh_my_zsh() {
    if [ ! -e ~/.oh-my-zsh ]; then
        # --keep-zshrc: the installer otherwise replaces ~/.zshrc with its
        # template, clobbering the one synced from this repo.
        # --unattended: skips chsh and the exec into zsh at the end, which
        # would stall the rest of this script until that shell exits.
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    else
        echo "oh-my-zsh already installed"
    fi
}

# Rust
install_rustup() {
    if [[ $(command -v rustup) == "" ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    else
        echo "rustup already installed: $(which rustup)"
    fi
}

setup_vim() {
    if [[ $(command -v vim) != "" ]]; then
        # Install vim-plug
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

        # Install vim dependencies.
        vim -c 'PlugInstall | qa'
    else
        echo "vim not installed, skipping setup"
    fi
}


# Install Process

# Additional non-default installs
if [ "${INSTALL_ALL}" = "yes" ]; then
    # Platform specific setup
    case $(uname) in
    Darwin)
        install_brew
        ;;

    Linux)
        install_linuxbrew
        ;;
    esac

    install_rustup

    # Install the brew bundle for my preferences.
    brew bundle --file="$DIR/Brewfile"
fi

# Sync configuration files. This must run before the oh-my-zsh install so that
# ~/.zshrc from this repo is already in place for it to keep.
"${DIR}/sync.sh" -o

install_oh_my_zsh

setup_vim
