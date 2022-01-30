#!/bin/sh
#
# Sync changes from local files into this repository so they can be committed
# for use on other machines.

set -e

R="$(dirname "$0")"

# Sync all files in the repo home/ directory already.
for f in $(find ./home -type f -not -name ".*" -not -name "*.md" | cut -c8-); do
    # Copy the "." version from the home directory. We omit the "." here to
    # make the times in the repo easier to work with.
    src="$HOME/.$f"
    dst="$R/home/$f"
    if [ -f "$src" ]; then
        cp "$src" "$dst"
    fi
done
