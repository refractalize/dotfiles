function! GetVisualSelection(range)
  if a:range
    return getline("'<")[getpos("'<")[2] - 1:getpos("'>")[2] - 2]
  else
    return ''
  endif
endfunction
