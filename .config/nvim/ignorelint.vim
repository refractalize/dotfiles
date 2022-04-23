command! -range IgnoreLint lua require('ignore-lint').ignore_lints(<range>, <line1>, <line2>)
nnoremap <Leader>i :IgnoreLint<CR>
vnoremap <Leader>i :IgnoreLint<CR>
