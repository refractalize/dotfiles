lua require'colorizer'.setup()

highlight QuickFixLine ctermfg=209 guifg=#fab795

" undercurl support with Kitty
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"

" italic comments

" nicer diff highlighting
if &background ==# 'dark'
else
  highlight DiffText term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#FFBF00
  highlight DiffChange term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#FFF19E gui=NONE
  highlight DiffDelete gui=NONE guibg=#FCF8E7 guifg=#D11C24
  highlight DiffAdd gui=NONE guifg=NONE guibg=#C7FFC6
endif
