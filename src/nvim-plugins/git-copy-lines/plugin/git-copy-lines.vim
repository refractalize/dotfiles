function! CopyGitRange(line1, count, range, mods, arg, ...)
  let url = substitute(execute(call('fugitive#BrowseCommand', [a:line1, a:count, a:range, 1, a:mods, a:arg] + a:000)), '^\n', '', '')
  let lang = ExtToLang(expand('%:e'))
  if a:range
    let text = GetVisualText(a:range)
  else
    let text = getline('.')
  endif

  let @+ = "```" . lang . "\n" . text . "\n```\n\n" . url
endfunction

function! ExtToLang(ext)
  if a:ext ==# 'mjs'
    return 'js'
  endif

  return a:ext
endfunction

command! -bar -bang -range=-1 -nargs=* -complete=customlist,fugitive#CompleteObject GCopy call CopyGitRange(<line1>, <count>, +"<range>", "<mods>", <q-args>)
