#!/bin/sh
#
# Sync changes from local files into this repository so they can be committed
# for use on other machines.

set -e

R="$(dirname "$0")"

# files that are identical between here and the local copy
HOME_FILES='
zshrc
vimrc
gitconfig
gitignore_global
editorconfig
prettierrc.yaml
tern-config
psqlrc
'

for f in $HOME_FILES; do
    # Copy the "." version from the home directory. We omit the "." here to
    # make the times in the repo easier to work with.
    cp "$HOME/.$f" "$R/home/$f";
done
