let $FZF_DEFAULT_OPTS .= ' --exact'
let g:fzf_layout = { 'down': '~40%' }

let g:fzf_history_dir = '~/.fzf-history'

" the default action on enter
function! OpenOneOrMoreSelectedFiles(files)
  if len(a:files) == 1
    exe 'e' a:files[0]
  else
    let files = map(a:files, { _index, file -> {'filename': file} })
    call setqflist(files, 'r')
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
  if len(a:buffer) > 0 && match(a:buffer, '\(^term:\)\|\(/\.git/\)') == -1 && filereadable(a:buffer) && filetype != 'fugitive'
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

function! Mru(onlyLocal, multi, query)
  let openBuffersTempFile = tempname()
  call writefile(['^' . getcwd()] + OpenBuffers(), openBuffersTempFile)

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

imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-l> <plug>(fzf-complete-line)
inoremap <expr> <c-x><c-l> fzf#vim#complete(fzf#wrap({
  \ 'prefix': '^.*$',
  \ 'source': 'rg -n ^ --color always',
  \ 'options': '--ansi --delimiter : --nth 3..',
  \ 'reducer': { lines -> join(split(lines[0], ':\zs')[2:], '') }}))
imap <c-x><c-b> <plug>(fzf-complete-buffer-line)

inoremap <expr> <c-x><c-f> fzf#vim#complete("rg --files <Bar> xargs grealpath --relative-to " . expand("%:h"))
inoremap <expr> <c-x><c-r> fzf#vim#complete(fzf#wrap({
  \ 'source': "rg --files <Bar> xargs grealpath --relative-to " . expand("%:h"),
  \ 'reducer': { lines -> fnamemodify(lines[0], ':e') ==# expand("%:e") ? fnamemodify(lines[0], ':r') : lines[0] }}))

" lookup recent command history
inoremap <expr> <c-x><c-h> fzf#vim#complete(fzf#wrap({
      \   'source': "zsh -c \"export HISTFILE=~/.zsh_history && fc -R && fc -rl 1 \| sed -E 's/[[:blank:]]*[[:digit:]]*\\*?[[:blank:]]*//'\"",
      \   'options': '--tiebreak index',
      \   'reducer': { lines -> join(map(lines, { _index, line -> substitute(line, '\\n', '\n', 'g') }), '\n') },
      \ }))

function! NodeRelativeFilename(filenames)
  let filename_with_ext = a:filenames[0]
  let filename = fnamemodify(filename_with_ext, ':e') ==# 'js' ? fnamemodify(filename_with_ext, ':r') : filename_with_ext

  if l:filename =~ '^\.'
    return l:filename
  else
    return './' . l:filename
  endif
endfunction

inoremap <expr> <c-x><c-j> fzf#vim#complete(fzf#wrap({
  \ 'reducer': function('NodeRelativeFilename'),
  \ 'source': "rg --files <Bar> xargs grealpath --relative-to " . expand("%:h"),
  \ }))

nnoremap <silent> <Leader><Leader> :Mru<cr>
vnoremap <silent> <Leader><Leader> :Mru<cr>
nnoremap <silent> <Leader>f :Mru!<cr>
vnoremap <silent> <Leader>f :Mru!<cr>
command! -bang -range Mru :call Mru(!<bang>0, 0, GetVisualText(<range>))
command! -bang -range MMru :call Mru(!<bang>0, 1, GetVisualText(<range>))

command! -bar -bang Mapsv call fzf#vim#maps("x", <bang>0)
command! -bar -bang Mapsi call fzf#vim#maps("i", <bang>0)
command! -bar -bang Mapso call fzf#vim#maps("o", <bang>0)
command! -bar -bang Mapsc call fzf#vim#maps("c", <bang>0)
command! -bar -bang Mapst call fzf#vim#maps("t", <bang>0)

nnoremap <silent> <Leader>w :Windows<cr>

function! SearchString(str)
    call histadd("cmd", "Rgs " . a:str)
    execute "Rgs " . a:str
endfunction

function! SearchRegex(str)
    call histadd("cmd", "Rg " . a:str)
    execute "Rg " . a:str
endfunction

vnoremap <leader>* <Cmd>call SearchString(GetVisualText(0))<CR>

nnoremap <silent> <Leader>* :call SearchRegex("\\b" . expand('<cword>') .  "\\b")<cr>

nnoremap <leader>G :Rg 
nnoremap <leader>r :SearchCurrentFilename<cr>
autocmd FileType eruby nnoremap <leader>r :call SearchRegex("\\b" . substitute(expand("%:t:r:r"), "^_", "", "") . "\\b")<cr>
nnoremap <leader>g :Rg<cr>
nnoremap <leader>l :BLines<cr>
command! -bang -nargs=* Rgs call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case --fixed-strings -- ".shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)

command! SearchCurrentFilename call SearchRegex("\\b" . expand("%:t:r") . "\\b")

function! RgReloadWithSort(query, fullscreen)
  let rgCommandBase = "rg --column --line-number --no-heading --color=always --smart-case "
  let rgCommand = rgCommandBase . " -- " . shellescape(a:query)
  let rgCommandSort = rgCommandBase . " --sortr path -- " . shellescape(a:query)

  call fzf#vim#grep(
    \ rgCommand,
    \ 1,
    \ fzf#vim#with_preview({'options': ['--tiebreak', 'index', '--bind', 'ctrl-s:reload:' . rgCommandSort]}),
    \ a:fullscreen
  \ )
endfunction

command! -bang -nargs=* Rg call RgReloadWithSort(<q-args>, <bang>0)

function! OpenFileInBranch(file, branch)
  exe 'Gedit ' . a:branch . ':' . a:file
endfunction

function RemoveDots(branch)
  return substitute(a:branch, '^\.*\|\.*$', '', 'g')
endfunction

function! ShowFileDiff(file, branch)
  let branch = RemoveDots(a:branch)
  exe 'tabnew'
  exe 'e ' . a:file
  exe 'Gdiffsplit! ' . branch
endfunction

function! ShowFileDiffs(files, branch)
  let action = remove(a:files, 0)
  echom action
  echom a:files
  if action == ''
    exe 'args' join(map(a:files, 'fnameescape(v:val)'), ' ')
  elseif action == 'alt-d'
    call map(a:files, { index, file -> ShowFileDiff(file, a:branch) })
  endif
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

command! -nargs=* -complete=customlist,fugitive#EditComplete GdiffFiles call fzf#run(fzf#wrap('GdiffFiles', {
    \ 'source': 'git diff --name-only ' . <q-args>,
    \ 'sink*': { files -> ShowFileDiffs(files, <q-args>) },
    \ 'options': [
      \ '--preview', 'git diff --color ' . <q-args> . ' -- {}',
      \ '--no-sort',
      \ '--expect', 'alt-d',
      \ '--multi',
      \ '--ansi',
      \ '--prompt', 'GdiffFiles> ',
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

function! ShowBranchFile(line, branch)
  echo line
endfunction

function! ShowBranchFiles(lines, branch)
  call map(a:lines, { index, line -> ShowBranchFile(line, a:branch) })
endfunction

command! -bang -nargs=* -complete=customlist,fugitive#EditComplete Gdiff call fzf#vim#grep(
  \ '{ git diff ' . <q-args> . ' | diff2vimgrep }',
  \ 0,
  \ {
    \ 'options': [
      \ '--tac',
      \ '--preview',
      \ 'if [[ {4} == -* ]]; then git show ' . RemoveDots(<q-args>) . ':{1} | bat --file-name {1} --plain --number -H {2} --color=always; else bat {1} --plain --number -H {2} --color=always; fi',
      \ '--preview-window',
      \ '+{2}-5/2',
    \ ],
  \ },
  \ <bang>0
\ )
