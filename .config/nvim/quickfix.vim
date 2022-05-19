function! SetQuickFix(range, add)
  if a:range
    let lines = getline("'<", "'>")
  else
    let lines = getline(1, '$')
  endif

  try
    let original_errorformat = &errorformat
    set errorformat=%f:%l

    if a:add
      caddexpr lines
    else
      cexpr lines
    endif
  finally
    let &errorformat = original_errorformat
  endtry
endfunction

command! -range SetQuickFix call SetQuickFix(<range>, 0)
command! -range AddToQuickFix call SetQuickFix(<range>, 1)
