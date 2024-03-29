#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Aliases
alias cls='printf "\033c"'

autoload bashcompinit && bashcompinit

# aws cli completions
if type aws_completer >/dev/null 2>&1; then
  complete -C "$(which aws_completer)" aws
fi

if type kubectl >/dev/null 2>&1; then 
  source <(kubectl completion zsh)
fi 

# terraform cli completions
complete -o nospace -C /usr/bin/terraform terraform

# let me use things like HEAD^ in git commands
unsetopt nomatch
