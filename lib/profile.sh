# Library style script for bash profile configuration.
#
# It is intended to be sourced in whatever bash file the current environment
# makes use of to initialize the shell. It is also intended to work on both
# Linux and Mac.

# Colorizing utilities
# http://stackoverflow.com/questions/4332478
# https://unix.stackexchange.com/a/269085
BLACK="$(tput setaf 0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
LIME_YELLOW="$(tput setaf 190)"
POWDER_BLUE="$(tput setaf 153)"
LIGHT_PURPLE="$(tput setaf 189)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
GRAY="$(tput setaf 7)"
NC="$(tput sgr0)"
BOLD="$(tput bold)"
BLINK="$(tput blink)"
REVERSE="$(tput smso)"
UNDERLINE="$(tput smul)"

# Set an environment for the development directory, by default using the
# Mac-specified one with a pretty logo on the folder.
DEV=${DEV:="$HOME/Developer"}

# Path customizations
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi
if [ -d "$DEV/bin" ]; then
    export PATH="$DEV/bin:$PATH"
fi

# Default editor
export EDITOR=vim
# Editor aliases
alias v='vim'
alias vi='vim'

# Navigation
alias dv='cd $DEV'

# Kubernetes
alias k=kubectl
# setup bash completion (kinda slow so commented out)
# source <(kubectl completion bash)
# source <(helm completion bash)

# Configure GPG for signing with the current terminal.
# ref: https://github.com/keybase/keybase-issues/issues/2798
export GPG_TTY
GPG_TTY=$(tty)

# Allow the watching of aliased commands: https://unix.stackexchange.com/a/25329
alias watch='watch '

# Utility commands
alias recwc='find . -type f | xargs wc -l'
alias ll='ls -l'
alias ds='du -hs * | gsort -h'
alias showports='sudo lsof -iTCP -sTCP:LISTEN -n -P'

# Golang
export GOPATH="$DEV/go"
export PATH="$PATH:$GOPATH/bin"

# Rust
[[ -e "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Python
# virtualenvwrapper setup (must initialize the script in the .zshrc)
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$DEV
export VIRTUALENVWRAPPER_PYTHON=$(which python3)

# Smart pwd command. References:
# shorten path: https://superuser.com/a/180267/669334
# sed for vars with slashes: https://stackoverflow.com/a/16790859/2528719
# Git working directory: https://stackoverflow.com/a/39923104/2528719
# Trim trailing chars: https://stackoverflow.com/a/5074995/2528719
smart_pwd_fn() {
    if hash smart-pwd 2>/dev/null; then
        # Use the much faster Go program if available, which does the same thing.
        # https://github.com/kujenga/gash
        smart-pwd
        return
    fi
    # set -x
    # git prefix with repo name or pwd.
    GIT=$(git rev-parse --show-prefix 2> /dev/null)
    if [ $? -eq 0 ]; then
        DIR="$(basename "$(git rev-parse --show-toplevel)")/$GIT"
    else
        DIR="$(pwd)"
    fi
    # strip trailing slash, replace $HOME with ~, shorten all but last.
    echo "$DIR" | \
        sed 's?/$??g' | \
        sed "s?$HOME?~?g" | \
        perl -F/ -ane 'print join( "/", map { $i++ < @F - 1 ?  substr $_,0,1 : $_ } @F)'
    # set +x
}

### FZF goodness, ref: https://github.com/junegunn/fzf/wiki/examples
### - awk-based unique filter from: https://stackoverflow.com/a/11532197/2528719

# NOTE: `history -s` is used to add various commands to the shell history so
# that the up arrow faciliates their re-use, more like normal commands.

## cd

# fd - cd to selected directory
fd() {
    local dir
    dir=$(rg --files --null | xargs -0 gdirname | awk '!x[$0]++' | fzf +m --height 40%) &&
    history -s cd "$dir" &&
    cd "$dir"
}

# fda - including hidden directories
fda() {
    local dir
    dir=$(rg --hidden --files --null | xargs -0 gdirname | awk '!x[$0]++' | fzf +m --height 40%) &&
    history -s cd "$dir" &&
    cd "$dir"
}

## Git

# fbr - checkout git branch
fbr() {
    local branches branch parsed_branch
    branches=$(git branch --all --sort=-committerdate) &&
    branch=$(echo "$branches" |
             fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m --height 40%) &&
    parsed_branch="$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")" &&
    history -s git checkout "$parsed_branch" &&
    git checkout "$parsed_branch"
}

# fco - checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
fco() {
    local tags branches target result
    tags=$(
        git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
    branches=$(
        git branch --all | grep -v HEAD |
        sed "s/.* //" | sed "s#remotes/[^/]*/##" |
        awk '!x[$0]++' | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
    target=$(
        (echo "$tags"; echo "$branches") |
    fzf --no-hscroll --no-multi --delimiter="\t" -n 2 \
        --ansi --preview="git log -200 --pretty=format:%s $(echo {+2..} |  sed 's/$/../' )" ) || return
    result="$(echo "$target" | awk '{print $2}')"
    history -s git checkout "$result"
    git checkout "$result"
}

### Bash prompt configuration.

if [ -n "$BASH_VERSION" ]; then
    # Reasoning for brackets around colors: https://unix.stackexchange.com/a/28828
    # git branch in the command prompt, dirty state disabled currently.
    # GIT_PS1_SHOWDIRTYSTATE=true
    # PS1="$GRAY\h$NC:$LIGHT_PURPLE\w$NC \u\$(__git_ps1)$NC \$ "
    # PS1="\h:\W \u\$(__git_ps1) \$ "
    # PS1="\h:\$(smart_pwd) \u\$(__git_ps1) \$ "
    PS1="\[$GRAY\]\h\[$NC\]:\[$LIGHT_PURPLE\]\$(smart_pwd_fn)\[$NC\] \u\$(__git_ps1)\[$NC\]\$ "
    # PS1="\t \h:\W \u\$(__git_ps1) \$ "
fi
