if ! defaults read net.kovidgoyal.kitty NSUserKeyEquivalents | grep -q "Hide kitty"; then
  defaults write net.kovidgoyal.kitty NSUserKeyEquivalents -dict-add "Hide kitty" '~^$\\U00a7'
fi

# This is for when running kitty from source
# cd kitty && make debug && python3 .
if ! defaults read org.python.python NSUserKeyEquivalents | grep -q "Hide Python"; then
  defaults write org.python.python NSUserKeyEquivalents -dict-add "Hide Python" '~^$\\U00a7'
fi
