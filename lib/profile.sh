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

### FZF goodness, ref: https://github.com/junegunn/fzf/wiki/examples
### - awk-based unique filter from: https://stackoverflow.com/a/11532197/2528719

## cd

# fd - cd to selected directory
fd() {
  local dir
  dir=$(rg --files --null | xargs -0 gdirname | awk '!x[$0]++' | fzf +m --height 40%) &&
  cd "$dir"
}

# fda - including hidden directories
fda() {
  local dir
  dir=$(rg --hidden --files --null | xargs -0 gdirname | awk '!x[$0]++' | fzf +m --height 40%) &&
  cd "$dir"
}

## Git

# fbr - checkout git branch
fbr() {
  local branches branch
  branches=$(git branch --all --sort=-committerdate) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m --height 40%) &&
  git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
}

# fco - checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
fco() {
  local tags branches target
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
  git checkout "$(echo "$target" | awk '{print $2}')"
}

### Bash prompt configuration.

# Reasoning for brackets around colors: https://unix.stackexchange.com/a/28828
# git branch in the command prompt, dirty state disabled currently.
# GIT_PS1_SHOWDIRTYSTATE=true
# PS1="$GRAY\h$NC:$LIGHT_PURPLE\w$NC \u\$(__git_ps1)$NC \$ "
# PS1="\h:\W \u\$(__git_ps1) \$ "
# PS1="\h:\$(smart_pwd) \u\$(__git_ps1) \$ "
PS1="\[$GRAY\]\h\[$NC\]:\[$LIGHT_PURPLE\]\$(smart_pwd_fn)\[$NC\] \u\$(__git_ps1)\[$NC\]\$ "
# PS1="\t \h:\W \u\$(__git_ps1) \$ "
