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
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
    # "vi" is installed in more environments than "vim" and otherwise generally
    # symlinked to vim, so we use that as the command name here.
    if [[ $(command -v vi) != "" ]]; then
        # Install vim-plug
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

        # Install vim dependencies.
        vi -c 'PlugInstall | qa'
    else
        echo "vim (vi) not installed, skipping setup"
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

install_oh_my_zsh

# Sync configuration files
"${DIR}/sync.sh" -o

setup_vim
