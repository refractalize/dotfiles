if ! defaults read net.kovidgoyal.kitty NSUserKeyEquivalents | grep -q "Hide kitty"; then
  defaults write net.kovidgoyal.kitty NSUserKeyEquivalents -dict-add "Hide kitty" '~^$\\U00a7'
fi

if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="no-cursor no-title"
    autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration
fi
