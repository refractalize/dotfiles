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

function! OpenBufferInTab(count, close = 0)
  let buf = bufnr()
  let tabcount = tabpagenr('$')

  if a:close
    close
  endif

  if a:count > 0 && a:count <= tabcount
    exe 'tabn' . a:count
    exe 'vnew'
  else
    exe 'tabnew'
  endif
  exe 'b ' . buf
endfunction

nnoremap <silent> <M-t> <Cmd>rightbelow call OpenBufferInTab(v:count)<CR>
nnoremap <silent> <M-T> <Cmd>rightbelow call OpenBufferInTab(v:count, v:true)<CR>

nnoremap <M-S-;> g<Tab>
nnoremap <M-O> <Cmd>tabonly<CR>
nnoremap <M-S-]> <Cmd>tabnext<CR>
nnoremap <M-S-[> <Cmd>tabprev<CR>
nnoremap <S-M-.> <Cmd>tabm +1 \| lua require('lualine').refresh({ scope = 'tabpage' })<CR>
nnoremap <S-M-,> <Cmd>tabm -1 \| lua require('lualine').refresh({ scope = 'tabpage' })<CR>
