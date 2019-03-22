export ZGEN_RESET_ON_CHANGE=(${HOME}/.zshrc ${HOME}/.zsh/*)
# git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then
  zgen oh-my-zsh

  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/nvm
  zgen load joshuarubin/zsh-direnv

  zgen load ~/.zsh
  zgen load ~/.zsh/prompt

  zgen save
fi
