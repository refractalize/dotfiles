function! GetVisualSelection(range)
  if a:range
    let end = (&selection ==# "exclusive" ? 2 : 1)
    return getline("'<")[getpos("'<")[2] - 1:getpos("'>")[2] - end]
  else
    return ''
  endif
endfunction
