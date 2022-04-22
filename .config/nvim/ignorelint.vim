command! -range IgnoreLint lua require('ignore-lint').ignore_lints(<range>)
nnoremap <Leader>i :IgnoreLint<CR>
vnoremap <Leader>i :IgnoreLint<CR>
