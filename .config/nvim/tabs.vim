nnoremap <M-1> 1gt
nnoremap <M-2> 2gt
nnoremap <M-3> 3gt
nnoremap <M-4> 4gt
nnoremap <M-5> 5gt
nnoremap <M-6> 6gt
nnoremap <M-7> 7gt
nnoremap <M-8> 8gt
nnoremap <M-9> 9gt
nnoremap <M-0> :tablast<cr>
nnoremap <M-{> :tabprevious<cr>
nnoremap <M-}> :tabnext<cr>

au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <M-§> :exe "tabn ".g:lasttab<cr>
