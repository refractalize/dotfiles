function! ReturnHighlightTerm(group, term)
  " Store output of group to variable
  let output = execute('hi ' . a:group)

  " Find the term we're looking for
  return matchstr(output, a:term.'=\zs\S*')
endfunction

function! SetIlluminateHighlight()
  execute "hi illuminatedWord gui=underline guibg=" . ReturnHighlightTerm("CursorLine", "guibg")
endfunction

augroup illuminate_augroup
  autocmd!
  autocmd VimEnter * call SetIlluminateHighlight()
  autocmd User ThemeChanged call SetIlluminateHighlight()
augroup END
