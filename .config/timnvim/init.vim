nnoremap <space> <Nop>
let mapleader=" "

set nocompatible               " be iMproved
filetype off                   " required!

lua <<LUA
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
LUA

lua <<LUA
require("lazy").setup({
  spec = {
    { import = "plugins" }
  },
  -- spec2 = bisect({
  --   'plugins.lsp',
  --   'plugins.treesitter',
  -- }),
  dev = {
    path = "~/src/nvim-plugins",
    patterns = { "refractalize" },
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  install = {
    missing = false
  }
})
LUA

lua <<LUA
local bisect = require('bisect')
bisect()
LUA

nmap <leader>cf :let @+=expand("%:.")<CR>
nmap <leader>cd :let @+=expand("%:h:.")<CR>
nmap <leader>cD :let @+=expand("%:p:h")<CR>
nmap <leader>cl :let @+=expand("%:.").":".line(".")<CR>
nmap <leader>cF :let @+=expand("%:p")<CR>

filetype plugin indent on

set undofile

set hidden
set shiftwidth=2
set tabstop=4
set expandtab
set smarttab
set hlsearch
" syntax manual
set path+=**     " allow searching all files and subdirectories in current directory
set number
set ruler
set laststatus=2
set scrolloff=3
set ignorecase
set smartcase
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
set diffopt+=linematch:60
set diffopt+=hiddenoff
set diffopt+=algorithm:patience
set diffopt+=indent-heuristic
set isfname-==
set mouse=a
set inccommand=nosplit
set signcolumn=yes:2
set termguicolors
set pumblend=20
set nofoldenable
set listchars=trail:·,nbsp:+,tab:\|·>
set list

au TextYankPost * silent! lua vim.highlight.on_yank({ higroup = 'Visual' })

" navigate long, wrapping lines
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
vnoremap <expr> k v:count == 0 ? 'gk' : 'k'
vnoremap <expr> j v:count == 0 ? 'gj' : 'j'

nnoremap gk k
nnoremap gj j
vnoremap gk k
vnoremap gj j

map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

" diffget on visual selection
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
" open the command buffer
set cedit=
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

nnoremap <silent> <leader>a :ArgWrap<CR>

" visual select last pasted text
" http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap gp `[v`]
" nnoremap gf :e <cfile><CR>

autocmd FileType fugitive set syntax=fugitive
autocmd FileType gitcommit set syntax=gitcommit
autocmd FileType vim set syntax=vim
autocmd FileType eruby set syntax=eruby
autocmd FileType xml set syntax=ON
autocmd FileType conf set syntax=ON
autocmd FileType git set syntax=ON

nnoremap <Leader>sn :set number!<CR>
" nnoremap <Leader>e :e %:h

source $HOME/.config/$NVIM_APPNAME/functions.vim
source $HOME/.config/$NVIM_APPNAME/style.vim
source $HOME/.config/$NVIM_APPNAME/diff.vim
source $HOME/.config/$NVIM_APPNAME/spelling.vim
source $HOME/.config/$NVIM_APPNAME/tabs.vim
source $HOME/.config/$NVIM_APPNAME/windows.vim
source $HOME/.config/$NVIM_APPNAME/titlestring.vim
source $HOME/.config/$NVIM_APPNAME/quickfix.vim
source $HOME/.config/$NVIM_APPNAME/watch.vim
source $HOME/.config/$NVIM_APPNAME/javascript.vim
source $HOME/.config/$NVIM_APPNAME/csharp.vim

let g:vim_json_conceal=0

lua require('quickfix').setup()
lua require('search')
lua require('page')
lua require('refractalize/renamefile')
lua require('refractalize/kittycopy').setup()
lua require('refractalize/largefiles')

lua vim.keymap.set({ "n", "v" }, "<D-y>", '"+y', { noremap = true })

autocmd VimResized * wincmd =

command! ProfileStart :profile start nvim-profile | profile func * | profile file *
command! ProfileStop :profile stop

lua <<EOF


function unload(name)
  package.loaded[name] = nil
end

EOF

" au FocusGained * wshada | rshada
