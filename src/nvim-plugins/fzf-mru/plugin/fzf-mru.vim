let g:mru_file = $HOME . '/.config/nvim/mru'

augroup mru
  au!

  au BufAdd,BufEnter,BufLeave,BufWritePost * call fzfmru#AddMruFile(expand('<afile>:p'), expand('<abuf>'))
augroup END

nnoremap <silent> <Leader><Leader> :Mru<cr>
vnoremap <silent> <Leader><Leader> :Mru<cr>
nnoremap <silent> <Leader>f :Mru!<cr>
vnoremap <silent> <Leader>f :Mru!<cr>
command! -bang -range Mru :lua unload('fzf-mru'); require'fzf-mru'.fzf_mru()
