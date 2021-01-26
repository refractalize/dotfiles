preexec() {
  # for Terminal current directory support
  print -Pn "\e]2; %~/ \a"

  # for timing commands
  timer=$(($(print -P %D{%s%6.})/1000))
}

autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr ' %F{green}+'
zstyle ':vcs_info:*' unstagedstr ' %F{yellow}#'
zstyle ':vcs_info:*' formats '%F{blue}{%F{cyan}%b%u%c%F{blue}} '
zstyle ':vcs_info:*' actionformats '%F{blue}{%F{cyan}%b %F{red}%a%u%c%F{blue}} '

setopt prompt_subst

precmd() {
  # for Terminal current directory support
  print -Pn "\e]2; %~/ \a"

  vcs_info

  if [[ -n $SSH_TTY ]]
  then
    local DISPLAY_HOST="%F{yellow}$(hostname) "
  else
    local DISPLAY_HOST=
  fi

  # for timing commands
  if [ $timer ]; then
    local now=$(($(print -P %D{%s%6.})/1000))
    elapsed=$(duration $(($now-$timer)))
    export PROMPT="$DISPLAY_HOST${vcs_info_msg_0_}(%F{green}$(date '+%H:%M:%S') +${elapsed}%F{blue}) %F{blue}%c %F{red}%(?..[%?] )%F{blue}λ%f "
    unset elapsed
    unset timer
  else
    export PROMPT="$DISPLAY_HOST${vcs_info_msg_0_}(%F{green}$(date '+%H:%M:%S')%F{blue}) %F{blue}%c %F{red}%(?..[%?] )%F{blue}λ%f "
  fi
}
