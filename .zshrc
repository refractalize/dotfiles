# Brew
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# Home
export PATH=~/bin:$PATH

# Oracle
export OCI_LIB_DIR=$(brew --prefix)/lib
export OCI_INC_DIR=$(brew --prefix)/lib/sdk/include

# Nice stuff
alias ls="ls -Gh"

export EDITOR=vim

export TERM=xterm-256color

PROMPT="%F{blue}%c %F{red}%(?..[%?] )%F{blue}λ%f "

# Proper Emacs key bindings
bindkey -e
bindkey "^[F" emacs-forward-word
bindkey "^[f" emacs-forward-word

# Proper emacs word boundaries
WORDCHARS=''

preexec() {
  # for Terminal current directory support
  print -Pn "\e]2; %~/ \a"

  # for timing commands
  timer=${timer:-$SECONDS}
}

precmd() {
  # for Terminal current directory support
  print -Pn "\e]2; %~/ \a"

  # for timing commands
  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    export PROMPT="%F{blue}%c %F{06}(${timer_show}s) %F{red}%(?..[%?] )%F{blue}λ%f "
    unset timer_show
    unset timer
  else
    export PROMPT="%F{blue}%c %F{red}%(?..[%?] )%F{blue}λ%f "
  fi
}

# completions
fpath=(/usr/local/share/zsh-completions $fpath)

autoload -Uz compinit
compinit

export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE=~/.zsh-history

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

export NVM_DIR="/Users/tim/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s ~/.env ] && . ~/.env

# NPM
export PATH=./node_modules/.bin:../node_modules/.bin:../../node_modules/.bin:../../../node_modules/.bin:$PATH

# Composer (PHP package manager)
export PATH=~/.composer/vendor/bin:$PATH

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(direnv hook zsh)"
