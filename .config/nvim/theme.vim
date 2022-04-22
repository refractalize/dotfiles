function! SetTheme(theme)
  let filename = $HOME . "/.config/nvim/themes/" . a:theme . ".vim"
  if filereadable(filename)
    execute "source " . $HOME . "/.config/nvim/themes/" . a:theme . ".vim"
  else
    execute "colorscheme " . a:theme
  endif

  execute "hi illuminatedWord gui=underline guibg=" . ReturnHighlightTerm("CursorLine", "guibg")
endfunction

function! EditTheme(theme)
  let originalFilename = system("readlink $HOME/.config/nvim/themes/" . a:theme . ".vim")
  let theme = originalFilename == '' ? a:theme . ".vim" : originalFilename
  execute "edit $HOME/.config/nvim/themes/" . theme
endfunction

function! AliasTheme(theme, alias)
  silent execute "!ln -sf " . a:theme . ".vim $HOME/.config/nvim/themes/" . a:alias . ".vim"
endfunction

command! -nargs=1 Theme call SetTheme(<f-args>)
command! -nargs=1 ThemeEdit call EditTheme(<f-args>)
command! -nargs=* ThemeAlias call AliasTheme(<f-args>)

if empty($THEME)
  source $HOME/.config/nvim/themes/default.vim
else
  let themes = json_decode(readfile($HOME . "/.config/themes.json", ''))
  let theme = themes[$THEME]["nvim"]
  call SetTheme(theme)
endif
