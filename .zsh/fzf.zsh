[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_COMPLETION_OPTS='--no-sort --exact --multi'
export FZF_DEFAULT_OPTS="--history=$HOME/.fzf-history/fzf --bind=ctrl-k:previous-history,ctrl-j:next-history,ctrl-n:down,ctrl-p:up,ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all --cycle --exact --color=light"
