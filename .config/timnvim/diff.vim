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

function! EditConflicts()
  wincmd T
  diffthis
  split
  wincmd k
  diffthis
  Gedit :2
  diffthis
  vsplit
  Gedit :1
  diffthis
  vsplit
  Gedit :3
  diffthis
  wincmd j
  normal ]n
endfunction

command! GeditConflicts call EditConflicts()
