preexec() {
  # for Terminal current directory support
  print -Pn "\e]2; %~/ \a"

  # for timing commands
  timer=${timer:-$SECONDS}
}

autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr ' %F{green}+'
zstyle ':vcs_info:*' unstagedstr ' %F{yellow}#'
zstyle ':vcs_info:*' formats ' %F{blue}(%F{cyan}%b%u%c%F{blue})'
zstyle ':vcs_info:*' actionformats ' %F{blue}(%F{cyan}%b %F{red}%a%u%c%F{blue})'

setopt prompt_subst

precmd() {
  # for Terminal current directory support
  print -Pn "\e]2; %~/ \a"

  vcs_info

  # for timing commands
  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    export PROMPT="%F{blue}%c${vcs_info_msg_0_} (%F{magenta}${timer_show}s%F{blue}) %F{red}%(?..[%?] )%F{blue}λ%f "
    unset timer_show
    unset timer
  else
    export PROMPT="%F{blue}%c${vcs_info_msg_0_} %F{red}%(?..[%?] )%F{blue}λ%f "
  fi
}
