set fillchars+=diff:╱

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

command! GPatch silent exec "!git diff HEAD " . expand("%") . " | pbcopy"
command! GApply silent exec "!pbpaste | git apply"
