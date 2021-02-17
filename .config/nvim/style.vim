let g:airline_powerline_fonts = 1
let g:airline_section_a = ''
let g:airline_section_b = ''

set background=dark

" horizon
colorscheme horizon
highlight QuickFixLine ctermfg=209 guifg=#fab795

" italic comments
highlight Comment gui=italic

" nicer diff highlighting
highlight DiffText term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#000000
highlight DiffChange term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#484540 gui=NONE
highlight DiffDelete gui=NONE guibg=#1e2127 guifg=#5f3a41
highlight DiffAdd gui=NONE guifg=NONE guibg=#3b453f

" one, onedark
" let g:airline_theme = 'onedark'
