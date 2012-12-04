set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

Bundle 'FuzzyFinder'
Bundle 'L9'
Bundle 'tomasr/molokai'
Bundle 'scrooloose/nerdtree'
Bundle 'kchmck/vim-coffee-script'
Bundle 'altercation/vim-colors-solarized'
Bundle 'tpope/vim-fugitive'
Bundle 'groenewege/vim-less'
Bundle 'tpope/vim-markdown'
Bundle 'featurist/vim-pogoscript'
Bundle 'tpope/vim-rails'
Bundle 'mattn/zencoding-vim'
Bundle 'tpope/vim-surround'
Bundle 'VimClojure'
Bundle 'sjl/gundo.vim'

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
colorscheme solarized
set laststatus=2
set scrolloff=3
set ignorecase
set smartcase
silent! set guifont="Source Code Pro:h11"
silent! set guifont=Source_Code_Pro:h10:cANSI
set backspace=2
set guioptions-=r
set guioptions-=m
set guioptions-=T

autocmd FileType pogo set shiftwidth=4
autocmd FileType html set shiftwidth=2
autocmd FileType css set shiftwidth=2
autocmd FileType javascript set shiftwidth=2
autocmd FileType less set shiftwidth=2

nnoremap <Leader>f :FufCoverageFile<CR>
nnoremap <Leader>b :FufBuffer<CR>
