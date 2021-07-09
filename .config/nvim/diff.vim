nnoremap <silent> <Leader>d :call DiffToggle()<CR>
function! DiffToggle()
  if &diff
    diffoff
  else
    diffthis
  endif
endfunction

nnoremap <silent> <Leader>w :call DiffIgnoreWhitespaceToggle()<CR>
function! DiffIgnoreWhitespaceToggle()
 if &diffopt =~ 'iwhite'
   set diffopt-=iwhite
 else
   set diffopt+=iwhite
 endif
endfunction

if executable('ag')
  set grepprg=ag\ --vimgrep
  set grepformat=%f:%l:%c:%m
endif
