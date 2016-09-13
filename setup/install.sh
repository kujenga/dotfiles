#!/bin/bash

set -euo pipefail

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

		for pkg in $PKGS; do
			echo "installing: $pkg"
			apt-get install "$pkg"
		done

		;;
esac
