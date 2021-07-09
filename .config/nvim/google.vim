function! Google(range, searchTermArg)
  let searchTerm = []

  let sel = a:range == 0 ? '' : getline("'<")[getpos("'<")[2] - 1:getpos("'>")[2] - 1]

  if sel != ''
    call add(searchTerm, sel)
  endif

  if a:searchTermArg != ''
    call add(searchTerm, a:searchTermArg)
  endif

  let escapedSearchTerm = luaeval('_A:gsub("\n", "\r\n"):gsub("([^%w])", function(c) return string.format("%%%02X", string.byte(c)) end)', join(searchTerm, ' '))
  call system("open http://www.google.fr/search\\?q=" . escapedSearchTerm)
endfunction

command! -nargs=* -range Google call Google(<range>, <q-args>)
