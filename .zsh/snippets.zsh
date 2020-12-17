alias zsp="zsh_snippets"
bindkey '^S^S' zsh-snippets-widget-expand  # CTRL-S CTRL-S (expand)
bindkey '^S^A' zsh-snippets-widget-list    # CTRL-S CTRL-A (list)

expand-snippet-or-complete() {
  local KEY
  local MATCH
  setopt extendedglob

  source $SNIPPET_FILE

  KEY=${LBUFFER%%(#m)[.\-+:|_a-zA-Z0-9]#}
  [[ ${zshSnippetArr[$MATCH]} != "" ]] && zsh-snippets-widget-expand || zle expand-or-complete
}

# zle -N expand-snippet-or-complete

# bindkey "^i" expand-snippet-or-complete
