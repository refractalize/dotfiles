if !exists('g:test#csharp#dotnettest2#file_pattern')
  let g:test#csharp#dotnettest2#file_pattern = '\v\.cs$'
endif

function! test#csharp#dotnettest2#test_file(file) abort
  if fnamemodify(a:file, ':t') =~# g:test#csharp#dotnettest2#file_pattern
    if exists('g:test#csharp#runner')
      return g:test#csharp#runner ==# 'dotnettest2'
    endif
    return 1
  endif
endfunction

function! test#csharp#dotnettest2#build_position(type, position) abort
  let file = a:position['file']
  let project_path = test#csharp#get_project_path(file)

  if a:type ==# 'nearest'
    let nearest_test = luaeval("require('csharp_nearest_test').nearest_test()")
    return [project_path, '--filter', 'FullyQualifiedName~' . nearest_test]
  elseif a:type ==# 'file'
    let names = luaeval("require('csharp_nearest_test').file_classes()")
    let filters = map(names, {_, name -> 'FullyQualifiedName~' . name})
    let filter = '"' . join(filters, '|') . '"'
    return [project_path, '--filter', filter]
  elseif a:type ==# 'suite'
    if !empty(project_path)
      return [project_path]
    else
      return []
    endif
  endif
endfunction

function! test#csharp#dotnettest2#build_args(args) abort
  let args = a:args
  return [join(args, ' ')]
endfunction

function! test#csharp#dotnettest2#executable() abort
  return 'dotnet test'
endfunction
