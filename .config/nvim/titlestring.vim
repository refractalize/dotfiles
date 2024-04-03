function! TitleString()
  let branch = v:lua.require('lualine.components.branch.git_branch').get_branch()
  let dir = $PROMPT_ICON != "" ? $PROMPT_ICON : fnamemodify(getcwd(),':t')
  if branch == ""
    return dir
  else
    return dir . "  " . branch
  endif
endfunction

set title
set titlestring=%{TitleString()}
