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

function! BaseName(filename)
  let basename = fnamemodify(a:filename, ":t:r")
  let productionBaseName = ProductionFilename(basename)

  if productionBaseName ==# 'index'
    return fnamemodify(a:filename, ":h:t") . '/' . basename
  else
    return basename
  endif
endfunction

function! FindAlternative()
  let basename = BaseName(expand("%"))
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

  if path[0] !=# '.'
    let modulePath = path
  else
    let relativePath = substitute(system("grealpath --relative-to " . expand("%:h") . " " . path), '\n\+$', '', '')

    if relativePath[0] !=# '.'
      let modulePath = './' . relativePath
    else
      let modulePath = relativePath
    endif
  endif

  return "import " . basepath . " from '" . modulePath . "'"
endfunction

autocmd FileType javascript inoremap <expr> <c-i> fzf#vim#complete(fzf#wrap({
  \ 'source': "rg --files \| sed 's/.*/.\\/&/' && [[ -f package.json ]] && jq -r '.dependencies + .devDependencies \| keys[]' package.json",
  \ 'reducer': { lines -> AddImport(lines) }}))

command! ToggleMochaOnly :lua require('toggle_mocha_only').toggle_mocha_only()<cr>
autocmd FileType javascript nnoremap <Leader>o <Cmd>ToggleMochaOnly<CR>

command! RunMochaTest :lua unload('mocha_nearest_test'); unload('ts_utils'); require('mocha_nearest_test').mocha_nearest_test()<cr>
autocmd FileType javascript nnoremap <Leader>tl <Cmd>RunMochaTest<CR>

command! ToggleImportRequre :lua unload('toggle_import_require'); unload('ts_utils'); require('toggle_import_require').toggle_import_require()<cr>
nnoremap <Leader>ti :ToggleImportRequre<CR>

command! ToggleAsyncFunction :lua unload('toggle_async_function'); unload('ts_utils'); require('toggle_async_function').toggle_async_function()<cr>
nnoremap <Leader>ta :ToggleAsyncFunction<CR>

function! FindNodeDependencyPath(directory, dependency)
  if a:directory == '/'
    return
  endif

  let dependencyDirectory = a:directory . "/node_modules/" . a:dependency

  if isdirectory(dependencyDirectory)
    return dependencyDirectory
  else
    return FindNodeDependencyPath(fnamemodify(a:directory, ':h'), a:dependency)
  endif
endfunction

function! ModuleName(path)
  let components = split(a:path, '/')
  if a:path =~ '^@'
    return join(components[0:1], '/')
  else
    return components[0]
  endif
endfunction

function! ModuleMain(dirname)
  let packageFilename = a:dirname . '/package.json'

  if filereadable(packageFilename)
    let package = json_decode(readfile(packageFilename))

    if has_key(package, 'main')
      return package['main']
    endif
  endif
endfunction

function! ResolveMain(dirname, moduleRelativeFilename)
  if len(a:moduleRelativeFilename) > 0
    return resolve(a:dirname . a:moduleRelativeFilename)
  else
    let main = ModuleMain(a:dirname)

    if main isnot 0
      return resolve(a:dirname . '/' . main)
    else
      return resolve(a:dirname)
    endif
  endif
endfunction

function! ResolveJavascriptImport(fname)
  if a:fname !~ '^\.'
    let fromFile = expand('%:p')
    let dirname = fnamemodify(fromFile, ':h')
    let moduleName = ModuleName(a:fname)
    let moduleRelativeFilename = a:fname[len(moduleName):-1]
    let found = FindNodeDependencyPath(dirname, moduleName)

    if found isnot 0
      return ResolveMain(found, moduleRelativeFilename)
    endif
  endif

  return a:fname
endfunction


autocmd FileType javascript setlocal includeexpr=ResolveJavascriptImport(v:fname)
autocmd FileType javascript setlocal isfname+=@-@
autocmd FileType javascript command! InstallLspTools FloatermNew npm i -g @fsouza/prettierd typescript-language-server typescript vscode-langservers-extracted
