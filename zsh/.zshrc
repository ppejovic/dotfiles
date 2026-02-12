# zimfw
ZIM_HOME=~/.zim
[[ -f ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh

# starship
eval "$(starship init zsh)"

# direnv
eval "$(direnv hook zsh)"
