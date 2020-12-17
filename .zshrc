export ZGEN_RESET_ON_CHANGE=(${HOME}/.zshrc ${HOME}/.zsh/*.zsh)
# git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then
  zgen oh-my-zsh

  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/nvm
  zgen oh-my-zsh plugins/fzf
  zgen oh-my-zsh plugins/web-search
  zgen load joshuarubin/zsh-direnv
  zgen load zdharma/history-search-multi-word
  zgen load 1ambda/zsh-snippets

  zgen load lincheney/fzf-tab-completion zsh

  zgen load ~/.zsh
  zgen load ~/.zsh/prompt
  zgen load ~/.secrets.zsh

  zgen save
fi
