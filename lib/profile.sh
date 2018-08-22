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

# Default editor
export EDITOR=vim
# Editor aliases
alias v='vim'
alias vi='vim'

# Kubernetes
alias k=kubectl
# setup bash completion (kinda slow so commented out)
# source <(kubectl completion bash)
# source <(helm completion bash)

# Allow the watching of aliased commands: https://unix.stackexchange.com/a/25329
alias watch='watch '

# Utility commands
alias recwc='find . -type f | xargs wc -l'
alias ll='ls -l'
alias ds='du -hs * | gsort -h'
alias showports='sudo lsof -iTCP -sTCP:LISTEN -n -P'

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

# Bash prompt configuration.
# Reasoning for brackets around colors: https://unix.stackexchange.com/a/28828
# git branch in the command prompt, dirty state disabled currently.
# GIT_PS1_SHOWDIRTYSTATE=true
# PS1="$GRAY\h$NC:$LIGHT_PURPLE\w$NC \u\$(__git_ps1)$NC \$ "
# PS1="\h:\W \u\$(__git_ps1) \$ "
# PS1="\h:\$(smart_pwd) \u\$(__git_ps1) \$ "
PS1="\[$GRAY\]\h\[$NC\]:\[$LIGHT_PURPLE\]\$(smart_pwd_fn)\[$NC\] \u\$(__git_ps1)\[$NC\]\$ "
# PS1="\t \h:\W \u\$(__git_ps1) \$ "
