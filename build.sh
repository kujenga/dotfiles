#!/bin/bash

set -euo pipefail
shopt -s dotglob

tar -cvpzf 'build.tgz' --directory='home' .
