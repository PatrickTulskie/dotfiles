local host='%m'
[[ -n $SSH_CONNECTION ]] && host='%n@%m'

PROMPT='%{$fg_bold[green]%}'"$host"'%\:%{$fg_bold[green]%}%p%{$fg_bold[blue]%}%c%{$fg_bold[green]%}$(git_prompt_info)%{$fg_bold[green]%} % %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX=" (%{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}*%{$fg[green]%})%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%})"
