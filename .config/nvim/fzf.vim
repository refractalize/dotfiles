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

inoremap <expr> <c-x><c-l> fzf#vim#complete(fzf#wrap({
  \ 'prefix': '^.*$',
  \ 'source': 'rg -n ^ --color always',
  \ 'options': '--ansi --delimiter : --nth 3..',
  \ 'reducer': { lines -> join(split(lines[0], ':\zs')[2:], '') }}))
imap <c-x><c-b> <plug>(fzf-complete-buffer-line)

" inoremap <expr> <c-x><c-r> fzf#vim#complete("rg --files <Bar> xargs grealpath --relative-to " . expand("%:h"))

" lookup recent command history
inoremap <expr> <c-x><c-h> fzf#vim#complete(fzf#wrap({
      \   'source': "zsh -c \"export HISTFILE=~/.zsh_history && fc -R && fc -rl 1 \| sed -E 's/[[:blank:]]*[[:digit:]]*\\*?[[:blank:]]*//'\"",
      \   'options': '--tiebreak index',
      \   'reducer': { lines -> join(map(lines, { _index, line -> substitute(line, '\\n', '\n', 'g') }), '\n') },
      \ }))

command! -bar -bang Mapsv call fzf#vim#maps("x", <bang>0)
command! -bar -bang Mapsi call fzf#vim#maps("i", <bang>0)
command! -bar -bang Mapso call fzf#vim#maps("o", <bang>0)
command! -bar -bang Mapsc call fzf#vim#maps("c", <bang>0)
command! -bar -bang Mapst call fzf#vim#maps("t", <bang>0)

function! SearchString(str)
    call histadd("cmd", "Rgs " . a:str)
    execute "Rgs " . a:str
endfunction

" vnoremap <leader>* <Cmd>call SearchString(GetVisualText(0))<CR>

function! SearchRegex(str)
    call histadd("cmd", "Rg " . a:str)
    execute "Rg " . a:str
endfunction

" nnoremap <silent> <Leader>* :call SearchRegex("\\b" . expand('<cword>') .  "\\b")<cr>

command! -bang -nargs=* Rgs
  \ call fzf#vim#grep(
  \   "rg --column --line-number --no-heading --color=always --smart-case --fixed-strings -- " . shellescape(<q-args>),
  \   1,
  \   fzf#vim#with_preview(),
  \   <bang>0
  \ )

command! -bang -nargs=* Rg 
  \ call fzf#vim#grep(
  \   "rg --column --line-number --no-heading --color=always --smart-case -- " . shellescape(<q-args>),
  \   1,
  \   fzf#vim#with_preview({'options': ['--tiebreak', 'index']}),
  \    <bang>0
  \ )

nnoremap <leader>G :Rg 
nnoremap <leader>g :Rg<cr>

nnoremap <leader>r :SearchCurrentFilename<cr>
command! SearchCurrentFilename call SearchRegex("\\b" . expand("%:t:r") . "\\b")
