# export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket-kitty-tab-$(kitty @ ls | jq ".[] | . as \$oswin | .tabs[] | . as \$tab | .windows[] | select(.id == $KITTY_WINDOW_ID) | \$tab.id")
