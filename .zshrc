export ZGEN_RESET_ON_CHANGE=(${HOME}/.zshrc ${HOME}/.zsh/*.zsh)
# git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then
  zgen load ~/.zsh/extras/homebrew.zsh

  zgen oh-my-zsh

  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/fzf
  zgen oh-my-zsh plugins/web-search
  zgen load joshuarubin/zsh-direnv

  zgen load lincheney/fzf-tab-completion zsh
  zgen load zsh-users/zsh-autosuggestions
  zgen load zdharma/fast-syntax-highlighting
  zgen load lukechilds/zsh-nvm

  zgen load ~/.secrets.zsh
  zgen load ~/.zsh
  zgen load ~/.zsh/prompt

  zgen save
fi
