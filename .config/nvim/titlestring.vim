function! TitleString()
  let branch = FugitiveHead(6)
  let dir = $PROMPT_ICON != "" ? $PROMPT_ICON : fnamemodify(getcwd(),':t')
  if branch == ""
    return dir
  else
    return dir . "  " . branch
  endif
endfunction

set title
set titlestring=%{TitleString()}
