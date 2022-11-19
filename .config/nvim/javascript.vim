let g:alternative_test_file_suffixes = [".spec", "Spec", ".test", "Test"]

function! FindFirst(filenames, fn)
  for f in a:filenames
    let found = a:fn(f)

    if found isnot v:null && found isnot 0
      return found
    endif
  endfor
endfunction

function! RemoveTestFilenamePart(filename, ending)
  let result = substitute(a:filename, escape(a:ending, '.') . '$', '', '')

  if result isnot a:filename
    return result
  endif
endfunction

function! ProductionFilename(filename)
  return FindFirst(g:alternative_test_file_suffixes, { ending -> RemoveTestFilenamePart(a:filename, ending) })
endfunction

function! FindAlternative()
  let basename = expand("%:t:r")
  let productionBaseName = ProductionFilename(basename)

  if productionBaseName isnot 0
    let alternative = findfile(productionBaseName)
  else
    let alternative = FindFirst(g:alternative_test_file_suffixes, { ending -> findfile(basename . ending) })
  endif

  if alternative isnot ''
    execute "e " . alternative
  endif
endfunction

autocmd FileType javascript set wildignore+=**/node_modules/** 
autocmd FileType javascript command! A call FindAlternative()

function AddImport(lines)
  let path = a:lines[0]
  let basepath = fnamemodify(path, ":t:r")
  let relativePath = substitute(system("realpath --relative-to " . expand("%:h") . " " . path), '\n\+$', '', '')

  if relativePath[0] !=# '.'
    let relativePath = './' . relativePath
  endif

  return "import " . basepath . " from '" . relativePath . "'"
endfunction

autocmd FileType javascript inoremap <expr> <c-i> fzf#vim#complete(fzf#wrap({
  \ 'source': "rg --files",
  \ 'reducer': { lines -> AddImport(lines) }}))

command! ToggleMochaOnly :lua require('toggle_mocha_only').toggle_mocha_only()<cr>
autocmd FileType javascript nnoremap <Leader>o <Cmd>ToggleMochaOnly<CR>

command! RunMochaTest :lua require('mocha_nearest_test').mocha_nearest_test()<cr>
autocmd FileType javascript nnoremap <Leader>tl <Cmd>RunMochaTest<CR>
