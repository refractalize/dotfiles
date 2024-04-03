command! WatchJq :lua vim.api.nvim_buf_set_option(0, 'filetype', 'json'); require('watch').start('jq {new:jq}', { stdin = true, filetype = 'json' })<cr>
command! WatchAwk :lua require('watch').start('gawk {new:gawk}', { stdin = true })<cr>
command! WatchNode :lua vim.api.nvim_buf_set_option(0, 'filetype', 'javascript'); require('watch').start('node --input-type=module', { stdin = true })<cr>
