# RubyGems
export PATH=/usr/local/Cellar/ruby/2.0.0-p247/bin:$PATH
# Brew
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# Home
export PATH=~/bin:$PATH
# NPM
export PATH=./node_modules/.bin:../node_modules/.bin:../../node_modules/.bin:../../../node_modules/.bin:$PATH

# Java
export PATH=/Library/Java/JavaVirtualMachines/jdk1.7.0_07.jdk/Contents/Home/bin:$PATH
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_07.jdk/Contents/Home

# Nice stuff
alias ls="ls -Gh"

export TERM=xterm-256color

PROMPT="%F{yellow}%m%f %F{blue}%c λ%f "

# Proper Emacs key bindings
bindkey "^[F" emacs-forward-word
bindkey "^[f" emacs-forward-word

# Proper emacs word boundaries
WORDCHARS=''

# for Terminal current directory support
precmd () {print -Pn "\e]2; %~/ \a"}
preexec () {print -Pn "\e]2; %~/ \a"}

# completions
fpath=(/usr/local/share/zsh-completions $fpath)

autoload -Uz compinit
compinit

export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE=~/.zsh-history
