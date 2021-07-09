lua require'colorizer'.setup()

highlight QuickFixLine ctermfg=209 guifg=#fab795

" undercurl support with Kitty
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"

let g:lightline = {}

source $HOME/.config/nvim/themes/current.vim

" italic comments

" nicer diff highlighting
if &background ==# 'dark'
else
  highlight DiffText term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#FFBF00
  highlight DiffChange term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#FFF19E gui=NONE
  highlight DiffDelete gui=NONE guibg=#FCF8E7 guifg=#D11C24
  highlight DiffAdd gui=NONE guifg=NONE guibg=#C7FFC6
endif

function! ReturnHighlightTerm(group, term)
   " Store output of group to variable
   let output = execute('hi ' . a:group)

   " Find the term we're looking for
   return matchstr(output, a:term.'=\zs\S*')
endfunction

augroup illuminate_augroup
  autocmd!
  autocmd VimEnter * execute "hi illuminatedWord gui=underline guibg=" . ReturnHighlightTerm("CursorLine", "guibg")
augroup END

function ReloadStatusLineConfig()
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction

function! SetTheme(theme)
  silent execute "!ln -sf " . a:theme . ".vim $HOME/.config/nvim/themes/current.vim"
  source $HOME/.config/nvim/themes/current.vim
  call ReloadStatusLineConfig()
  execute "hi illuminatedWord gui=underline guibg=" . ReturnHighlightTerm("CursorLine", "guibg")
  silent execute "!theme " . a:theme
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
