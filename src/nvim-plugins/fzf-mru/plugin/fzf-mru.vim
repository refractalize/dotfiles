let g:mru_file = $HOME . '/.config/nvim/mru'

augroup mru
  au!

  au BufAdd,BufEnter,BufLeave,BufWritePost * call fzfmru#AddMruFile(expand('<afile>:p'), expand('<abuf>'))
augroup END
