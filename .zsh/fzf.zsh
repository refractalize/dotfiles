[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_COMPLETION_OPTS='--no-sort --exact --multi'
export FZF_DEFAULT_OPTS="--history=$HOME/.fzf-history/fzf --bind=ctrl-k:previous-history,ctrl-j:next-history,ctrl-n:down,ctrl-p:up,alt-a:select-all,alt-d:deselect-all,alt-t:toggle-all --cycle --exact --color=dark"
