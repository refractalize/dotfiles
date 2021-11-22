export HISTSIZE=1000000000
export SAVEHIST=1000000000

setopt sharehistory

# only browse local history with ^N ^P
function up-line-or-history-local () {
        zle set-local-history 1
        zle up-line-or-history
        zle set-local-history 0
}
zle -N up-line-or-history-local
bindkey "^P" up-line-or-history-local

function down-line-or-history-local () {
        zle set-local-history 1
        zle down-line-or-history
        zle set-local-history 0
}
zle -N down-line-or-history-local
bindkey "^N" down-line-or-history-local

backup-zsh-history () {
  PREV=$(wc -l ~/.zsh_history.bak | awk '{ print $1 }')
  CURR=$(wc -l ~/.zsh_history | awk '{ print $1 }')

  if [[ -z $PREV || $PREV -le $CURR ]]
  then
    cp ~/.zsh_history ~/.zsh_history.bak
  else
    echo "!! ZSH history was truncated ($PREV down to $CURR entries) !!"
  fi
}

backup-zsh-history
