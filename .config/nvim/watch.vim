command! WatchJq :lua require('watch').start('jq {new:jq}', { stdin = true, filetype = 'json' })<cr>
command! WatchAwk :lua require('watch').start('awk {new:awk}', { stdin = true })<cr>
command! WatchNode :lua require('watch').start('node --input-type=module', { stdin = true })<cr>
