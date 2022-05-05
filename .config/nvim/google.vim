function! Google(sel, searchTermArg)
  let searchTerm = []

  if a:sel != ''
    call add(searchTerm, a:sel)
  endif

  if a:searchTermArg != ''
    call add(searchTerm, a:searchTermArg)
  endif

  let escapedSearchTerm = luaeval('_A:gsub("\n", "\r\n"):gsub("([^%w])", function(c) return string.format("%%%02X", string.byte(c)) end)', join(searchTerm, ' '))
  call system("open http://www.google.fr/search\\?q=" . escapedSearchTerm)
endfunction

command! -nargs=* -range Google call Google(GetVisualSelection(<range>), <q-args>)
