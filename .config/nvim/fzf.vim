let $FZF_DEFAULT_OPTS .= ' --exact'
let g:fzf_layout = { 'down': '~40%' }

let g:fzf_history_dir = '~/.fzf-history'

let g:fzf_action = {
  \ 'alt-t': 'tab split',
  \ 'alt-s': 'split',
  \ 'alt-v': 'vsplit'
  \ }

let g:mru_file = $HOME . '/.config/nvim/mru'

function! AddMruFile(buffer)
  if len(a:buffer) > 0 && match(a:buffer, '\(^term:\)\|\(/\.git/index$\)') == -1 && filereadable(a:buffer) && filetype != 'fugitive'
    call writefile([a:buffer], g:mru_file, 'a')
  endif

  if str2nr(system('wc -l ' . g:mru_file)) > 2000
    let tmpfile = tempname()
    " remove duplicate entries (there are usually a lot)
    call system('tail -r ' . g:mru_file . ' | awk ''!counts[$0]++'' > ' . tmpfile . ' && mv ' . tmpfile . ' ' . g:mru_file)

    if str2nr(system('wc -l ' . g:mru_file)) > 1000
      " only keep the most recent 1000 entries
      call system('tail -n 1000 ' . g:mru_file . ' > ' . tmpfile . ' && mv ' . tmpfile . ' ' . g:mru_file)
    end
  endif
endfunction

augroup mru
  au!

  au BufAdd,BufEnter,BufLeave,BufWritePost * call AddMruFile(expand('<afile>:p'))
augroup END

function! OpenBuffers()
  return map(filter(range(1, bufnr('$')), 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"'), "fnamemodify(bufname(v:val), ':p')")
endfunction

function! Mru(onlyLocal)
  let openBuffersTempFile = tempname()
  call writefile(['^' . getcwd()] + OpenBuffers(), openBuffersTempFile)

  if a:onlyLocal
    let grep = ' | grep -f ' . openBuffersTempFile
  else
    let grep = ''
  endif

  call fzf#run(fzf#wrap('mru', fzf#vim#with_preview({
    \ 'source': '(tail -r ' . g:mru_file . ' | cut -f1' . l:grep .  ' | sed s:' . getcwd() . '/:: && rm ' . openBuffersTempFile . ' && rg --files --hidden) | awk ''!counts[$0]++''',
    \ 'options': [
      \ '--no-sort',
      \ '--prompt', a:onlyLocal ? 'mru> ' : 'mru-all> ',
      \ '--tiebreak', 'end'
    \ ]
    \ })))
endfunction

imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-l> <plug>(fzf-complete-line)
imap <c-x><c-b> <plug>(fzf-complete-buffer-line)

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
      \ '--preview', 'git show --format=format: $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1) -- ' . expand('%') . ' | delta --width=$FZF_PREVIEW_COLUMNS'
    \ ]}
  \ ),
\ 0)

imap <c-x><c-f> <plug>(fzf-complete-path)
