if [[ "$OSTYPE" == darwin* ]]; then
  alias ls="ls -hG"
else
  alias ls="ls -h --color=auto"
fi
