function! OpenFileInBranch(file, branch)
  exe 'Gedit ' . a:branch . ':' . a:file
endfunction

function! RemoveDots(branch)
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

command! Gdm GdiffFiles origin/master...

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

