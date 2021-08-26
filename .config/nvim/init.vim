nnoremap <space> <Nop>
let mapleader=" "

set nocompatible               " be iMproved
filetype off                   " required!

lua require('plugins')

" visual copy
" Option+C (macOS + Kitty)
" at the end of ~/.config/kitty/kitty.conf
" map cmd+c send_text all \x1b\x63
vnoremap <M-y> "+y

command! Code :silent execute "!code -g " . expand('%') . ":" . line(".") | :redraw!

" set the search patten to the visually highlighted text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

nnoremap <silent> <Leader>v :e ~/.config/nvim/init.vim<cr>

nmap <leader>cf :let @+=expand("%")<CR>
nmap <leader>cl :let @+=expand("%").":".line(".")<CR>
nmap <leader>cF :let @+=expand("%:p")<CR>

filetype plugin indent on

set exrc   " enable per-directory .vimrc files
set secure " disable unsafe commands in local .vimrc files
set undofile

set hidden
set shiftwidth=2
set tabstop=4
set expandtab
set smarttab
set hlsearch
syntax manual
set path+=**     " allow searching all files and subdirectories in current directory
set number
set ruler
set cursorline
let g:rehash256 = 1
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
set guicursor+=n-v-c-sm:block-Cursor,i-ci-ve:ver25-CursorIM
set complete-=i
set nofileignorecase " make sure we use exact case on macos
set splitbelow
set splitright
set virtualedit=block " we can select beyond the end of the line in visual block, useful for vim-sandwich
set diffopt+=vertical " diffs are always shown left/right
set isfname-==
set mouse=a
set inccommand=nosplit
set signcolumn=yes:1
set title
set titlestring=nvim\ %{getcwd()}
set termguicolors

nnoremap <Leader>e :e %:h

" navigate long, wrapping lines
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
vnoremap <expr> k v:count == 0 ? 'gk' : 'k'
vnoremap <expr> j v:count == 0 ? 'gj' : 'j'

nnoremap gk k
nnoremap gj j
vnoremap gk k
vnoremap gj j

nnoremap <M-j> <C-W>j
nnoremap <M-k> <C-W>k
nnoremap <M-l> <C-W>l
nnoremap <M-h> <C-W>h
nnoremap <M-;> <C-W>p
nnoremap <M-r> <C-W>r
nnoremap <M-x> <C-W>x
nnoremap <M-R> <C-W>R
nnoremap <M-s> <C-W>s
nnoremap <M-v> <C-W>v
nnoremap <M-o> <C-W>o
nnoremap <M-=> <C-W>=
nnoremap <M-t> :tabnew<cr>
nnoremap <M-w> <C-W>c
nnoremap <M-d> :Gdiff<cr>
nnoremap <M-D> :Gdiff origin/master...<cr>
nnoremap <M-g> :G<cr>

nnoremap <M-1> 1gt
nnoremap <M-2> 2gt
nnoremap £ 3gt
nnoremap <M-4> 4gt
nnoremap <M-5> 5gt
nnoremap <M-6> 6gt
nnoremap <M-7> 7gt
nnoremap <M-8> 8gt
nnoremap <M-9> 9gt
nnoremap <M-0> :tablast<cr>

map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

nnoremap <silent> <M-J> :exe "resize -2"<CR>
nnoremap <silent> <M-K> :exe "resize +2"<CR>
nnoremap <silent> <M-L> :exe "vertical resize +2"<CR>
nnoremap <silent> <M-H> :exe "vertical resize -2"<CR>

" Go to tab by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>

vnoremap <leader>o :diffget<cr>

" from :help emacs-keys
" start of line
cnoremap <C-A>		<Home>
" back one character
cnoremap <C-B>		<Left>
" delete character under cursor
cnoremap <C-D>		<Del>
" end of line
cnoremap <C-E>		<End>
" forward one character
cnoremap <C-F>		<Right>
" recall newer command-line
cnoremap <C-N>		<Down>
" recall previous (older) command-line
cnoremap <C-P>		<Up>
" back one word
cnoremap <M-b>	<S-Left>
" forward one word
cnoremap <M-f>	<S-Right>
" delete previous word
cnoremap <M-BS> <C-W>

au TabLeave * let g:lasttab = tabpagenr()

nnoremap <silent> <leader>a :ArgWrap<CR>

" visual select last pasted text
" http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap gp `[v`]
nnoremap gf :e <cfile><CR>

autocmd FileType fugitive set syntax=fugitive
autocmd FileType gitcommit set syntax=gitcommit
autocmd FileType vim set syntax=vim
autocmd FileType eruby set syntax=eruby
autocmd FileType xml set syntax=ON
autocmd FileType conf set syntax=ON
autocmd FileType git set syntax=ON

nnoremap <Leader>sn :set number!<CR>
nnoremap <Leader>sl :set cursorline!<CR>
nnoremap <Leader>e :e %:h

source $HOME/.config/nvim/fzf.vim
source $HOME/.config/nvim/style.vim
source $HOME/.config/nvim/google.vim
source $HOME/.config/nvim/diff.vim
source $HOME/.config/nvim/spelling.vim
source $HOME/.config/nvim/terminal.vim

nnoremap <leader>n :NvimTreeToggle<CR>

command! -nargs=1 ProfileStart :profile start <args> | profile func * | profile file *
command! ProfileStop :profile stop

autocmd BufWritePost plugins.lua source <afile> | PackerCompile
