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
nnoremap <M-[> :tabprevious<cr>
nnoremap <M-]> :tabnext<cr>
nnoremap <M-W> :tabclose<cr>

function! OpenBufferInTab(count)
  echom a:count
  let buf = bufnr()
  if a:count > 0
    exe 'tabn' . a:count
    exe 'vnew'
  else
    exe 'tabnew'
  endif
  exe 'b ' . buf
endfunction

command! -count=0 OpenBufferInTab call OpenBufferInNewTab(<count>)

" nnoremap <silent> <M-t> :OpenBufferInTab<CR>
nnoremap <silent> <M-t> :<c-u>call OpenBufferInTab(v:count)<CR>

au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <M-`> :exe "tabn ".g:lasttab<cr>
nnoremap <silent> <M-O> :tabonly<CR>
