#!/bin/bash

set -euo pipefail
shopt -s dotglob

mkdir -p dist

tar -cvpzf 'dist/build.tgz' --directory='home' .
