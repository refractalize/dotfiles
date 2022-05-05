export DISABLE_AUTO_TITLE=true

function set_win_title(){
  DIR=${PROMPT_ICON:-$PWD:t}
  BR=$(git branch --show-current 2>/dev/null)

  if [[ -n $BR ]]
  then
    TITLE="$DIR ($BR)"
  else
    TITLE="$DIR"
  fi

  echo -ne "\033]0;$TITLE\007"
}

precmd_functions+=(set_win_title)
