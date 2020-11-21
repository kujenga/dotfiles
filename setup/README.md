# Setup processes

For mac, the following steps are followed:
- Setup an SSH key with the following secure [1] approach:
```sh
ssh-keygen -o -a 100 -t ed25519
```
- Clone this repository into `~/Developer/init`
- Run `./setup/install.sh` from within that cloned repository
