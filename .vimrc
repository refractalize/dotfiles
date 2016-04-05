set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle
" required!
Plugin 'VundleVim/Vundle.vim'

Plugin 'tomasr/molokai'
Plugin 'tpope/vim-vinegar'
Plugin 'tpope/vim-abolish'
Plugin 'kchmck/vim-coffee-script'
Plugin 'altercation/vim-colors-solarized'
Plugin 'tpope/vim-fugitive'
Plugin 'groenewege/vim-less'
Plugin 'tpope/vim-markdown'
Plugin 'featurist/vim-pogoscript'
Plugin 'tpope/vim-rails'
Plugin 'mattn/emmet-vim'
Plugin 'tpope/vim-surround'
Plugin 'VimClojure'
Plugin 'sjl/gundo.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tpope/vim-cucumber'
Plugin 'godlygeek/tabular'
Plugin 'junegunn/goyo.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'michaeljsmith/vim-indent-object'
Plugin 'pangloss/vim-javascript'
Plugin 'vim-scripts/summerfruit256.vim'
Plugin 'leafgarland/typescript-vim'
Plugin 'rking/ag.vim'
Plugin 'maksimr/vim-jsbeautify'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Bundle 'honza/vim-snippets'
Plugin 'AndrewRadev/sideways.vim'
Plugin 'ludovicchabant/vim-lawrencium'
Plugin 'mxw/vim-jsx'
Plugin 'AndrewVos/vim-git-navigator'
Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-jdaddy'
Plugin 'gregsexton/gitv'
Plugin 'tpope/vim-commentary'
Plugin 'scrooloose/syntastic'
Plugin 'dbext.vim'
Plugin 'moll/vim-node'

call vundle#end()
filetype plugin indent on

" emmet
let g:user_emmet_settings = {
  \  'html' : {
  \    'empty_element_suffix': ' />'
  \  },
  \  'jsx' : {
  \    'extends': 'html',
  \    'attribute_name': {'class': 'class'},
  \  }
  \}

" ag.vim
nnoremap <Leader>* *:AgFromSearch<CR>
let g:ag_prg="ag --column --ignore-dir=bower_components --ignore-dir=common/js --ignore-dir=imd_system --ignore-dir=quack_template"

" vim-jsbeautify
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>

" vim-airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#syntastic#enabled = 1

" sideways.vim
nnoremap <c-h> :SidewaysLeft<cr>
nnoremap <c-l> :SidewaysRight<cr>

omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:solarized_termcolors= 256
let g:solarized_termtrans = 1

let g:solarized_bold = 1
let g:solarized_underline = 1
let g:solarized_italic = 1
" let g:solarized_contrast = "high"
" let g:solarized_visibility= "high"

set exrc   " enable per-directory .vimrc files
set secure " disable unsafe commands in local .vimrc files

set hidden
set shiftwidth=4
set tabstop=4
set expandtab
set smarttab
set hlsearch
syntax on
set path+=**     " allow searching all files and subdirectories in current directory
set number
set ruler
set background=dark
colorscheme molokai
set laststatus=2
set scrolloff=3
set ignorecase
set smartcase
set cursorline
silent! set guifont="Source Code Pro:h11"
silent! set guifont=Source_Code_Pro:h10:cANSI
set backspace=2
set guioptions-=r
set guioptions-=m
set guioptions-=T

if has("win32") || has("win64")
    set directory=$TMP
else
    set shell=bash
endif

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1

let g:syntastic_error_symbol = '✗'
let g:syntastic_style_error_symbol = '✠'
let g:syntastic_warning_symbol = '∆'
let g:syntastic_style_warning_symbol = '≈'
highlight SyntasticErrorSign ctermfg=196 guifg=#ff0000
highlight SyntasticWarningSign ctermfg=226 guifg=#ffff00

let g:syntastic_javascript_checkers = ['eslint']

" ctrl-p
nnoremap <Leader>b :CtrlPBuffer<CR>
nnoremap <Leader>f :CtrlP<CR>
let g:ctrlp_custom_ignore = { 'dir': '\v[\/](\.git|\.hg|\.svn|node_modules)$' }
let g:ctrlp_working_path_mode = 'a'

autocmd FileType pogo set shiftwidth=2
autocmd FileType html set shiftwidth=2
autocmd FileType css set shiftwidth=2
autocmd FileType javascript set shiftwidth=2
autocmd FileType less set shiftwidth=2

function! ShowSpecIndex()
  call setloclist(0, [])

  for line_number in range(1,line('$'))
    if getline(line_number) =~ '^ *\(\<its\?\>\|\<describe\>\|\<context\>\)'
      let expr = printf('%s:%s:%s', expand("%"), line_number, substitute(getline(line_number), ' ', nr2char(160), ''))
      laddexpr expr
    endif
  endfor

  lopen

  " hide filename and linenumber
  set conceallevel=2 concealcursor=nc
  syntax match qfFileName /^[^|]*|[^|]*| / transparent conceal
endfunction

nnoremap <Leader>si :call ShowSpecIndex()<cr>

if &term =~ '^screen'
    " tmux knows the extended mouse mode
    set ttymouse=xterm2
endif

noremap <S-+> <C-w> +

" remap 'increase number' since C-a is captured by tmux/screen
" Easier increment/decrement
nnoremap + <C-a>
nnoremap _ <C-x>
" CTags
"
" $PATH appears different to vim for some reason and hence wrong ctags gets picked
" until then, you need to manually override ctags in /usr/bin/ with those from homebrew
" TODO fix vim path
map <Leader>rt :!ctags --extra=+f -R *<CR><CR>

" visual select last pasted text
" http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap gp `[v`]

function! MochaOnly()
  let line = getline(".")
  if match(line, "\\<\\(it\\|context\\|describe\\)\\.only\\>") > 0
    let newline = substitute(line, "\\<\\(it\\|context\\|describe\\)\\.only\\>", "\\1", "")
    call setline(".", newline)
  else
    let newline = substitute(line, "\\<\\(it\\|context\\|describe\\)\\>", "\\1.only", "")
    call setline(".", newline)
  endif
endfunction

nnoremap <Leader>o :call MochaOnly()<cr>

command! Requires execute "Ag -s \"require\\(\\s*['\\\\\\\"][^'\\\\\\\"]*" . expand('%:t:r') . "[^'\\\\\\\"]*['\\\\\\\"]\\s*\\)\""
