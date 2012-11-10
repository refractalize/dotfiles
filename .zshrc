# RubyGems
export PATH=/usr/local/Cellar/ruby/1.9.3-p194/bin:$PATH
# Brew
export PATH=/usr/local/bin:$PATH
# Home
export PATH=~/bin:$PATH
# NPM
export PATH=./node_modules/.bin:../node_modules/.bin:../../node_modules/.bin:../../../node_modules/.bin:$PATH
export NODE_PATH=/usr/local/share/npm/lib/node_modules
export PATH=/usr/local/share/npm/bin:$PATH

# Java
export PATH=/Library/Java/JavaVirtualMachines/jdk1.7.0_07.jdk/Contents/Home/bin:$PATH
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_07.jdk/Contents/Home

# RVM
[[ -s "/Users/tim/.rvm/scripts/rvm" ]] && source "/Users/tim/.rvm/scripts/rvm"

# Nice stuff
alias ls="ls -Gh"

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
