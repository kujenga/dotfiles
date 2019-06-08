# ref: https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
eval light_purple='$FG[189]'
eval light_blue='$FG[069]'
eval light_gray='$FG[253]'

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"

PROMPT='${ret_status} %{$light_purple%}$(smart_pwd_fn)%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$light_blue%}(%{$light_gray%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$light_blue%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$light_blue%})"
