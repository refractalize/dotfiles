bindkey -e
bindkey "^[F" emacs-forward-word
bindkey "^[f" emacs-forward-word
bindkey "^[y" yank-pop

bindkey '^[[1;5C' emacs-forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3;5~' kill-word
bindkey '^H' backward-kill-word

# Proper emacs word boundaries
WORDCHARS=''
