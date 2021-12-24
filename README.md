# dotfiles

Shared configuration files and setup scripts files for setting up new and
maintaining existing machines.

## Usage

- Setup an SSH key with the following command:
```sh
ssh-keygen -o -a 100 -t ed25519
```
- Clone this repository into `~/Developer/dotfiles`
- Run `./install.sh` from within that cloned repository

## Directories

- `home` - files that are intended to go in the home directory.
- `lib` - files that are imported to provide utilities and configuration for the
  machine.
- `macos` - files that are used for setup of a macOS machine.

## References

- [dotfiles.github.io][dotfiles]
- [Customizing GitHub Codespaces][ghCodespaceDotfiles]
- Using GNU Stow: http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html (not currently utilized)


<!-- Links -->
[dotfiles]: https://dotfiles.github.io/
[ghCodespaceDotfiles]: https://docs.github.com/en/codespaces/customizing-your-codespace/personalizing-codespaces-for-your-account#dotfiles
