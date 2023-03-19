function! theme#SetTheme(theme)
  let filename = $HOME . "/.config/nvim/themes/" . a:theme . ".vim"
  if filereadable(filename)
    execute "source " . $HOME . "/.config/nvim/themes/" . a:theme . ".vim"
  else
    execute "colorscheme " . a:theme
  endif

  " doautocmd User ThemeChanged
endfunction

function! theme#EditTheme(theme)
  let originalFilename = system("readlink $HOME/.config/nvim/themes/" . a:theme . ".vim")
  let theme = originalFilename == '' ? a:theme . ".vim" : originalFilename
  execute "edit $HOME/.config/nvim/themes/" . theme
endfunction

function! theme#AliasTheme(theme, alias)
  silent execute "!ln -sf " . a:theme . ".vim $HOME/.config/nvim/themes/" . a:alias . ".vim"
endfunction

function! s:ThemeNames()
  let themes = json_decode(readfile($HOME . "/.config/themes.json", ''))
  return map(keys(themes), { i, k -> themes[k]["nvim"] })
endfunction

function! theme#CompleteTheme(argLead, cmdLine, cursorPos)
  return filter(s:ThemeNames(), { i, t -> a:argLead ==# '' ? 1 : t[0:len(a:argLead) - 1] ==# a:argLead })
endfunction

function! s:CurrentTheme()
  if !empty($THEME)
    return $THEME
  elseif filereadable('.theme')
    return readfile('.theme')[0]
  elseif filereadable('~/.config/current-theme')
    return readfile('~/.config/current-theme')[0]
  else
    return 'default'
  endif
endfunction

function! theme#SetupCurrentTheme()
  let themes = json_decode(readfile($HOME . "/.config/themes.json", ''))
  let theme = themes[s:CurrentTheme()]["nvim"]
  call theme#SetTheme(theme)
endfunction
