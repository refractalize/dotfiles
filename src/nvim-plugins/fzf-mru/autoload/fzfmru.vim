function! fzfmru#AddMruFile(buffer, bufnum)
  let filetype = getbufvar(str2nr(a:bufnum), '&filetype')
  if len(a:buffer) > 0 && match(a:buffer, '\(^term:\)\|\(/\.git/\)') == -1 && filereadable(a:buffer) && filetype != 'fugitive'
    call writefile([localtime() . ' ' . a:buffer], g:mru_file, 'a')
  endif
endfunction

function! s:OpenBuffers()
  return map(filter(range(1, bufnr('$')), 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"'), "fnamemodify(bufname(v:val), ':p')")
endfunction

function! fzfmru#Mru(onlyLocal, query)
  let openBuffersTempFile = tempname()
  call writefile(['^' . getcwd()] + s:OpenBuffers(), openBuffersTempFile)

  if a:onlyLocal
    let grep = '-c --always-include ' . openBuffersTempFile
  else
    let grep = ''
  endif

  let options = {
    \ 'source': 'rg --files --hidden | CLICOLOR_FORCE=1 fzf-mru ~/.config/nvim/mru ' . l:grep . ' && rm ' . openBuffersTempFile,
    \ 'placeholder': '{}',
    \ 'options': [
      \ '--no-sort',
      \ '--ansi',
      \ '--nth=1',
      \ '--multi',
      \ '--delimiter= ',
      \ '--prompt', a:onlyLocal ? 'mru> ' : 'mru-all> ',
      \ '--tiebreak', 'end',
    \ ]
  \ }

  if a:query isnot 0
    call add(options['options'], '--query')
    call add(options['options'], a:query)
  endif

  call fzf#run(fzf#wrap('mru', fzf#vim#with_preview(options)))
endfunction
