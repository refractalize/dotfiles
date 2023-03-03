nnoremap <M-j> <C-W>j
nnoremap <M-k> <C-W>k
nnoremap <M-l> <C-W>l
nnoremap <M-h> <C-W>h
nnoremap <M-;> <C-W>p
nnoremap <M-r> <C-W>r
nnoremap <M-x> <C-W>x
nnoremap <M-R> <C-W>R
nnoremap <M-s> <C-W>s
nnoremap <M-v> <C-W>v
nnoremap <M-o> <C-W>o
nnoremap <M-=> <C-W>=
tnoremap <M-T> <C-\><C-N><C-W>Ti
nnoremap <M-w> <C-W>c
nnoremap <M-g> :G<cr>

nnoremap <silent> <M-J> :exe "resize -2"<CR>
nnoremap <silent> <M-K> :exe "resize +2"<CR>
nnoremap <silent> <M-L> :exe "vertical resize +2"<CR>
nnoremap <silent> <M-H> :exe "vertical resize -2"<CR>

" https://stackoverflow.com/a/14068971
augroup CursorLine
  au!
  au VimEnter * setlocal cursorline
  au WinEnter * setlocal cursorline
  au BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END
