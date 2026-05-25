if [[ -f /run/.containerenv ]]
then
  eval "$(uv generate-shell-completion zsh)"
  eval "$(uvx --generate-shell-completion zsh)"
fi
