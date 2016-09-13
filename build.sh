#!/bin/bash

set -euo pipefail
shopt -s dotglob

# target directory for distributions
mkdir -p 'dist'

# setup temporary build directory
mkdir -p '.tmp'
cp home/* .tmp/
cp -r setup .tmp/

# create the tarball
tar -cvpzf 'dist/build.tgz' --directory '.tmp' .

# clean up temporary build directory
rm -rf '.tmp'
