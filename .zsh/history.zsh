setopt sharehistory

# only browse local history with ^N ^P
function up-line-or-history-local () {
        zle set-local-history 1
        zle up-line-or-history
        zle set-local-history 0
}
zle -N up-line-or-history-local
bindkey "^P" up-line-or-history-local

function down-line-or-history-local () {
        zle set-local-history 1
        zle down-line-or-history
        zle set-local-history 0
}
zle -N down-line-or-history-local
bindkey "^N" down-line-or-history-local
