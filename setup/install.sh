#!/bin/bash

set -euo pipefail

# Install Rust
curl https://sh.rustup.rs -sSf | sh
. "$HOME/.cargo/env"
# Install ripgrep from source
cargo install ripgrep

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
# allow "go get" to fetch private repos with ssh keys
# https://gist.github.com/shurcooL/6927554
git config --global url."git@github.com:".insteadOf "https://github.com/"

# desired packages to install
PKGS='tree'

# Platform specific setup
case $(uname) in
	Darwin)
		type brew >/dev/null 2>&1 || { echo >&2 "I require Homebrew but it's not installed.  Aborting."; exit 1; }

		for pkg in $PKGS; do
			echo "installing: $pkg"
			brew install "$pkg"
		done

		;;

	Linux)
		type apt-get >/dev/null 2>&1 || { echo >&2 "I require apt-get but it's not installed.  Aborting."; exit 1; }

		SYS_PKG='build-essential'

		for pkg in $SYS_PKG; do
			echo "installing system package $pkg"
			sudo apt-get install -y "$pkg"
		done

		for pkg in $PKGS; do
			echo "installing: $pkg"
			sudo apt-get install -y "$pkg"
		done

		;;
esac
