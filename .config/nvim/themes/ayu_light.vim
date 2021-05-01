let ayucolor="light"
let g:airline_theme = 'ayu'
let g:indentLine_color_gui = '#EED9BE'
colorscheme ayu

highlight DiffText term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#F2D9CD
highlight DiffChange term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#FAE5DB gui=NONE
highlight clear DiffDelete
highlight DiffDelete guifg=#FF7733 guibg=White
highlight DiffAdd gui=NONE guifg=NONE guibg=#DEEAC0
highlight ALEError cterm=undercurl gui=undercurl guisp=#FF3333
highlight ALEWarning cterm=undercurl gui=undercurl guisp=#FF7733
highlight Comment gui=italic
