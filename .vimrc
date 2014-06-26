set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'
Bundle 'tomasr/molokai'
Bundle 'tpope/vim-vinegar'
Bundle 'kchmck/vim-coffee-script'
Bundle 'altercation/vim-colors-solarized'
Bundle 'tpope/vim-fugitive'
Bundle 'groenewege/vim-less'
Bundle 'tpope/vim-markdown'
Bundle 'featurist/vim-pogoscript'
Bundle 'tpope/vim-rails'
Bundle 'mattn/emmet-vim'
Bundle 'tpope/vim-surround'
Bundle 'VimClojure'
Bundle 'sjl/gundo.vim'
Bundle 'kien/ctrlp.vim'
Bundle 'tpope/vim-cucumber'
Bundle 'godlygeek/tabular'
Bundle 'junegunn/goyo.vim'
Bundle 'airblade/vim-gitgutter'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'jelera/vim-javascript-syntax'
Bundle 'vim-scripts/summerfruit256.vim'
Bundle 'leafgarland/typescript-vim'

" Ag
Bundle 'rking/ag.vim'
nnoremap <Leader>* *:AgFromSearch<CR>
let g:agprg="ag --column --ignore-dir=bower_components --ignore-dir=common/js --ignore-dir=imd_system --ignore-dir=quack_template"

Bundle 'maksimr/vim-jsbeautify'
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>

Bundle 'bling/vim-airline'
let g:airline_powerline_fonts = 1

set hidden
set shiftwidth=4
set tabstop=4
set expandtab
set smarttab
set hlsearch
filetype plugin on
filetype indent on
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

" ctrl-p
" set wildignore+=*.o,*.obj,.git*,*.rbc,*.class,.svn,vendor/gems/*,*/tmp/*,*.so,*.swp,*.zip,*/images/*,*/cache/*,scrapers/products/*,bower_components/*,node_modules/*
nnoremap <Leader>b :CtrlPBuffer<CR>
nnoremap <Leader>f :CtrlP<CR>
let g:ctrlp_working_path_mode = 0
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files']

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

function! Camel()
  let [lnum, start] = searchpos("[$_a-zA-Z][$_a-zA-Z0-9 ]*[$_a-zA-Z0-9]", "bn")
  let [lnum, end] = searchpos("[$_a-zA-Z][$_a-zA-Z0-9 ]*[$_a-zA-Z0-9]", "ne")
  let line = getline(".")
  let identifier = line[start - 1 : end - 1]
  if start > 1
      let firstPart = line[0 : start - 2]
  else
      let firstPart = ""
  endif

  let lastPart = line[end :]

  let camel = substitute(identifier, "\\([a-zA-Z$_]\\)\\s\\+\\([a-zA-Z$_]\\)", "\\1\\u\\2", "g")

  let newLine = firstPart . camel . lastPart

  call setline(".", newLine)
endfunction

func! SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

nnoremap <Leader>c :call Camel()<cr>
