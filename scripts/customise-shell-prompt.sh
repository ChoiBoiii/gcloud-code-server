#!/bin/sh

## customise the google cloud shell bash prompt.
export PS1='🌀 \e[1m\033[38;5;202m\]\u@ndsn-shell \e[0m\[\033[00m\]in \e[1m\[\033[1;34m\]\w\e[0m$([[ -n $DEVSHELL_PROJECT_ID ]] && printf " \[\033[1;33m\](%s)" ${DEVSHELL_PROJECT_ID} )\[\033[00m\]'
if [[ -n $TMUX ]]; then
  export PS1+='\[\033k$([[ -n $DEVSHELL_PROJECT_ID ]] && printf "(%s)" ${DEVSHELL_PROJECT_ID} || printf "cloudshell")\033\\\]'
fi
export PS1+="\033[38;5;2m\]\$(__git_ps1 ' [⎇ %s]')\[\033[00m\] ↣ "
