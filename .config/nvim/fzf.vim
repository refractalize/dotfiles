let $FZF_DEFAULT_OPTS .= ' --exact'
let g:fzf_layout = { 'down': '~40%' }

let g:fzf_history_dir = '~/.fzf-history'

" the default action on enter
function! OpenOneOrMoreSelectedFiles(files)
  if len(a:files) == 1
    exe 'e' a:files[0]
  else
    exe 'args' join(map(a:files, 'fnameescape(v:val)'), ' ')
  endif
endfunction

let g:fzf_action = {
  \ 'alt-t': 'tab split',
  \ 'alt-s': 'split',
  \ 'alt-v': 'vsplit',
  \ '': function("OpenOneOrMoreSelectedFiles")
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

function! Mru(onlyLocal, multi)
  let openBuffersTempFile = tempname()
  call writefile(['^' . getcwd()] + OpenBuffers(), openBuffersTempFile)

  if a:onlyLocal
    let grep = '-c --always-include ' . openBuffersTempFile
  else
    let grep = ''
  endif

  let options = {
    \ 'source': 'rg --files --hidden | CLICOLOR_FORCE=1 fzf-mru ~/.config/nvim/mru ' . l:grep . ' && rm ' . openBuffersTempFile,
    \ 'placeholder': '{1}',
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

  call fzf#run(fzf#wrap('mru', fzf#vim#with_preview(options)))
endfunction

imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-l> <plug>(fzf-complete-line)
imap <c-x><c-b> <plug>(fzf-complete-buffer-line)

" lookup recent command history
inoremap <expr> <c-x><c-h> fzf#vim#complete(fzf#wrap({
      \   'source': "zsh -c \"export HISTFILE=~/.zsh_history && fc -R && fc -rl 1 \| sed -E 's/[[:blank:]]*[[:digit:]]*\\*?[[:blank:]]*//'\"",
      \   'options': '--tiebreak index',
      \ }))

nnoremap <silent> <Leader><Leader> :Mru<cr>
nnoremap <silent> <Leader>f :Mru!<cr>
command! -bang Mru :call Mru(!<bang>0, 0)
command! -bang MMru :call Mru(!<bang>0, 1)

command! -bar -bang Mapsv call fzf#vim#maps("x", <bang>0)
command! -bar -bang Mapsi call fzf#vim#maps("i", <bang>0)
command! -bar -bang Mapso call fzf#vim#maps("o", <bang>0)
command! -bar -bang Mapsc call fzf#vim#maps("c", <bang>0)
command! -bar -bang Mapst call fzf#vim#maps("t", <bang>0)

function! NodeRelativeFilename(lines)
  let fn = substitute(tlib#file#Relative(join(a:lines), expand('%:h')), '\.[^.]*$', '', '')
  if l:fn =~ '^\.'
    return l:fn
  else
    return './' . l:fn
  endif
endfunction

inoremap <expr> <c-x><c-j> fzf#vim#complete(fzf#wrap({
  \ 'reducer': function('NodeRelativeFilename'),
  \ 'source': 'rg --files --hidden',
  \ }))

function! SearchString(str)
    call histadd("cmd", "Rgs " . a:str)
    execute "Rgs " . a:str
endfunction

function! SearchRegex(str)
    call histadd("cmd", "Rg " . a:str)
    execute "Rg " . a:str
endfunction

function! SearchOperator(type)
    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        return
    endif

    call SearchString(@@)
endfunction

vnoremap <leader>* :<c-u>call SearchOperator(visualmode())<cr>

nnoremap <silent> <Leader>* :call SearchRegex("\\b" . expand('<cword>') .  "\\b")<cr>

nnoremap <leader>G :Rg 
nnoremap <leader>g :Rg<cr>
nnoremap <leader>l :BLines<cr>
command! -bang -nargs=* Rgs call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case --fixed-strings -- ".shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)

function! RgReloadWithSort(query, fullscreen)
  let rgCommandBase = "rg --column --line-number --no-heading --color=always --smart-case "
  let rgCommand = rgCommandBase . " -- " . shellescape(a:query)
  let rgCommandSort = rgCommandBase . " --sortr path -- " . shellescape(a:query)

  call fzf#vim#grep(rgCommand, 1, fzf#vim#with_preview({'options': ['--tiebreak', 'index', '--bind', 'ctrl-s:reload:' . rgCommandSort]}), a:fullscreen)
endfunction

command! -bang -nargs=* Rg call RgReloadWithSort(<q-args>, <bang>0)

function! OpenFileInBranch(file, branch)
  exe 'Gedit ' . a:branch . ':' . a:file
endfunction

command! -nargs=1 Gtree call fzf#run(fzf#wrap('GTree', {
    \ 'source': 'git ls-tree --name-only -r ' . <q-args>,
    \ 'placeholder': '{1}',
    \ 'sink': { file -> OpenFileInBranch(file, <f-args>) },
    \ 'options': [
      \ '--preview', 'git show ' . <q-args> . ':{} | bat --color always --decorations never --file-name {}',
      \ '--no-sort',
      \ '--ansi',
      \ '--nth=1',
      \ '--delimiter= ',
      \ '--prompt', 'GTree> ',
      \ '--tiebreak', 'end',
    \ ]
    \ }))

command! Gdiffbranch call fzf#run(fzf#wrap('Gdiffbranch', {
    \ 'source': 'git diff --name-only origin/master...',
    \ 'options': [
      \ '--preview', 'git diff --color origin/master... -- {}',
      \ '--no-sort',
      \ '--multi',
      \ '--ansi',
      \ '--prompt', 'Gdiffbranch> ',
      \ '--tiebreak', 'end',
    \ ]
    \ }))

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
nnoremap <leader>b :Gdiffbranch<cr>
