let $FZF_DEFAULT_OPTS .= ' --exact'
let g:fzf_layout = { 'down': '~40%' }

let g:fzf_history_dir = '~/.fzf-history'

let g:fzf_action = {
  \ 'alt-t': 'tab split',
  \ 'alt-s': 'split',
  \ 'alt-v': 'vsplit'
  \ }

let g:mru_file = $HOME . '/.config/nvim/mru'

function! AddMruFile(buffer, bufnum)
  let filetype = getbufvar(str2nr(a:bufnum), '&filetype')
  if len(a:buffer) > 0 && match(a:buffer, '\(^term:\)\|\(/\.git/index$\)') == -1 && filereadable(a:buffer) && filetype != 'fugitive'
    call writefile([localtime() . ' ' . a:buffer], g:mru_file, 'a')
  endif
endfunction

augroup mru
  au!

  au BufAdd,BufEnter,BufLeave,BufWritePost * call AddMruFile(expand('<afile>:p'), expand('<abuf>'))
augroup END

function! OpenBuffers()
  return map(filter(range(1, bufnr('$')), 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"'), "fnamemodify(bufname(v:val), ':p')")
endfunction

function! HandleMruEntry(files)
  if len(a:files) > 1
    exe 'args ' . join(map(a:files, 'split(v:val)[0]'), ' ')
  else
    exe 'e ' . split(a:files[0])[0]
  endif
endfunction

function! Mru(onlyLocal)
  let openBuffersTempFile = tempname()
  call writefile(['^' . getcwd()] + OpenBuffers(), openBuffersTempFile)

  if a:onlyLocal
    let grep = '-c --always-include ' . openBuffersTempFile
  else
    let grep = ''
  endif

  let Fn = function("HandleMruEntry")

  " \ 'sink': function("HandleMruEntry"),

  call fzf#run(fzf#wrap('mru', fzf#vim#with_preview({
    \ 'source': 'rg --files --hidden | CLICOLOR_FORCE=1 fzf-mru ~/.config/nvim/mru ' . l:grep . ' && rm ' . openBuffersTempFile,
    \ 'placeholder': '{1}',
    \ 'sink*': function("HandleMruEntry"),
    \ 'options': [
      \ '--no-sort',
      \ '--ansi',
      \ '--nth=1',
      \ '--multi',
      \ '--bind', 'alt-a:select-all,alt-d:deselect-all',
      \ '--delimiter= ',
      \ '--prompt', a:onlyLocal ? 'mru> ' : 'mru-all> ',
      \ '--tiebreak', 'end',
    \ ]
    \ })))
endfunction

inoremap <c-x><c-k> <plug>(fzf-complete-word)
inoremap <c-x><c-l> <plug>(fzf-complete-line)
inoremap <c-x><c-b> <plug>(fzf-complete-buffer-line)

nnoremap <silent> <Leader><Leader> :Mru<cr>
nnoremap <silent> <Leader>f :Mru!<cr>
command! -bang Mru :call Mru(!<bang>0)

command! -bar -bang Mapsv call fzf#vim#maps("x", <bang>0)
command! -bar -bang Mapsi call fzf#vim#maps("i", <bang>0)
command! -bar -bang Mapso call fzf#vim#maps("o", <bang>0)
command! -bar -bang Mapsc call fzf#vim#maps("c", <bang>0)

inoremap <expr> <c-x><c-j> fzf#vim#complete(fzf#wrap({
  \ 'reducer': function('NodeRelativeFilename'),
  \ 'source': 'rg --files --hidden',
  \ }))

nnoremap <silent> <Leader>* :call SearchRegex("\\b" . expand('<cword>') .  "\\b")<cr>

nnoremap <leader>G :Rg 
nnoremap <leader>g :Rg<cr>
nnoremap <leader>l :BLines<cr>
command! -bang -nargs=* Rgs call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case --fixed-strings -- ".shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)

command! -nargs=* Log call fzf#vim#buffer_commits(
  \ fzf#vim#with_preview({
    \ "placeholder": "",
    \ "options": [
      \ '--preview', 'git show --format=format: $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1) -- ' . expand('%') . ' | delta --width=$FZF_PREVIEW_COLUMNS',
      \ '--tiebreak', 'index'
    \ ]}
  \ ),
\ 0)

imap <c-x><c-f> <plug>(fzf-complete-path)
