set fillchars+=diff:╱

nnoremap <silent> <Leader>dd :call DiffToggle()<CR>
function! DiffToggle()
  if &diff
    diffoff
  else
    diffthis
  endif
endfunction

nnoremap <silent> <Leader>dw :call DiffIgnoreWhitespaceToggle()<CR>
function! DiffIgnoreWhitespaceToggle()
 if &diffopt =~ 'iwhite'
   set diffopt-=iwhite
 else
   set diffopt+=iwhite
 endif
endfunction

command! GPatchCopy silent exec "!git diff HEAD " . expand("%") . " | pbcopy"
command! GPatchPaste silent exec "!pbpaste | git apply"
