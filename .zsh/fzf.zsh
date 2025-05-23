if [[ $OSTYPE == darwin* ]]; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
else
  [ -f /usr/share/zsh/site-functions/fzf ] && source /usr/share/zsh/site-functions/fzf
fi
export FZF_COMPLETION_OPTS='--no-sort --exact --multi'
mkdir -p $HOME/.fzf-history
export FZF_DEFAULT_OPTS="--history=$HOME/.fzf-history/fzf --bind=ctrl-k:previous-history,ctrl-j:next-history,ctrl-n:down,ctrl-p:up,alt-a:select-all,alt-d:deselect-all,alt-t:toggle-all --cycle --exact --color=dark"
export FZF_ALT_C_COMMAND="fd -t d ."
