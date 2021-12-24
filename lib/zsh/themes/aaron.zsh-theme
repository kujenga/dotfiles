# Color definitions
# ref: https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
eval light_purple='$FG[189]'
eval light_blue='$FG[069]'
eval light_gray='$FG[253]'

# Green when success from last command, red otherwise.
local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"

PROMPT='${ret_status} %{$light_purple%}$(smart_pwd_fn)%{$reset_color%} $(git_prompt_info)'

# When we are in an SSH session, add user and hostname information.
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    PROMPT="%n@%m $PROMPT"
fi

# Overrides for theme variables
# https://github.com/ohmyzsh/ohmyzsh/wiki/Design#variables-used-by-themes

# Git overrides
ZSH_THEME_GIT_PROMPT_PREFIX="%{$light_blue%}(%{$light_gray%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$light_blue%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$light_blue%})"
