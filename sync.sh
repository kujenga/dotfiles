#!/bin/sh
#
# Sync changes from local files into this repository so they can be committed
# for use on other machines.

set -e

R="$(dirname "$0")"

DIRECTION='in'

while getopts 'out:h' opt; do
    case "$opt" in
        o)
            echo "Copying missing files to home directory..."
            DIRECTION='out'
            ;;
        O)
            echo "Overwriting files in home directory..."
            DIRECTION='overwrite'
            ;;

        ?|h)
            echo "Usage: $(basename $0) [-a] [-b] [-c arg]"
            exit 1
            ;;
    esac
done
shift "$(($OPTIND -1))"

# Sync all files in the repo home/ directory already.
for f in $(find ./home -type f -not -name ".*" -not -name "*.md" | cut -c8-); do
    # Copy the "." version from the home directory. We omit the "." here to
    # make the times in the repo easier to work with.
    live="$HOME/.$f"
    store="$R/home/$f"

    case "$DIRECTION" in
        out)
            if [ ! -f "$live" ]; then
                echo "Initializing: $store -> $live"
                mkdir -p "$(dirname "$live")"
                cp "$store" "$live"
            else
                echo "File already present: $live"
            fi
	    ;;

        overwrite)
            echo "Overwriting: $store -> $live"
            mkdir -p "$(dirname "$live")"
            cp "$store" "$live"
	    ;;

        in)
            if [ -f "$live" ]; then
                echo "Syncing: $live -> $store"
                cp "$live" "$store"
            else
                echo "Skipping sync for: $store"
            fi
	    ;;

    esac
done
