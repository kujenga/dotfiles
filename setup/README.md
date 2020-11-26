# Setup processes

For mac, the following steps are followed:

## General Setup

- System Preferences
  - Three finger drag in accessibility
  - Caps lock to escape
  - Increase key repeat all the way, and delay to one below the fastest
  - Switch clock to 24 hour time under "Language & Region"
- Install 1Password
- Install Firefox

## Setup Development Environment

- Setup an SSH key with the following secure [1] approach:
```sh
ssh-keygen -o -a 100 -t ed25519
```
- Clone this repository into `~/Developer/init`
- Run `./setup/install.sh` from within that cloned repository

### Setup GPG Keys

TODO
