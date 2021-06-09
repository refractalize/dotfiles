nnoremap <space> <Nop>
let mapleader=" "

set nocompatible               " be iMproved
filetype off                   " required!

call plug#begin('~/.vim/plugged')

Plug 'tomasr/molokai'
Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'joshdick/onedark.vim'
Plug 'rakr/vim-one'
Plug 'ntk148v/vim-horizon'
Plug 'ayu-theme/ayu-vim'
Plug 'Lokaltog/vim-monotone'
" Plug 'Yggdroot/indentLine'
Plug 'overcache/NeoSolarized'
Plug 'mhartington/oceanic-next'
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive' " git commands
Plug 'tpope/vim-rhubarb' " github helpers for vim-fugitive
Plug 'junegunn/gv.vim'
Plug 'groenewege/vim-less'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-abolish'
Plug 'featurist/vim-pogoscript'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-surround' " add/remove/change quotes, parens
Plug 'tpope/vim-rails'
Plug 'junegunn/vim-easy-align'
Plug 'mbbill/undotree'
Plug 'tpope/vim-cucumber'
Plug 'godlygeek/tabular' " format tables of data
Plug 'michaeljsmith/vim-indent-object' " treat indented sections of code as vim objects
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'jparise/vim-graphql'
Plug 'pangloss/vim-javascript'
Plug 'RRethy/vim-illuminate'
Plug 'vim-scripts/summerfruit256.vim'
Plug 'maksimr/vim-jsbeautify'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'AndrewRadev/linediff.vim'
Plug 'Chiel92/vim-autoformat'
Plug 'direnv/direnv.vim'
Plug 'itchyny/lightline.vim'
Plug 'SirVer/ultisnips'
Plug 'nvim-lua/completion-nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'tpope/vim-unimpaired' " [c ]c ]l [l etc, for navigating git changes, lint errors, search results, etc
Plug 'tpope/vim-eunuch' " file unix commands, :Delete, :Move, etc
Plug 'tpope/vim-jdaddy' " JSON manipulation
Plug 'tpope/vim-commentary' " make lines comments or not
Plug 'tpope/vim-repeat' " repeat complex commands with .
Plug 'tpope/vim-dadbod'
Plug 'moll/vim-node'
Plug 'FooSoft/vim-argwrap' " expanding and collapsing lists
Plug 'google/vim-jsonnet' " jsonnet language support
Plug 'jxnblk/vim-mdx-js'
let g:vcoolor_disable_mappings = 1
Plug 'KabbAmine/vCoolor.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'wsdjeg/vim-fetch'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'lewis6991/gitsigns.nvim'

" completion
let g:deoplete#enable_at_startup = 1
Plug 'shougo/deoplete-lsp'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" json and jsonl support
Plug 'elzr/vim-json' 
let g:vim_json_syntax_conceal = 0

Plug 'vim-scripts/indentpython.vim'

Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'
Plug 'JuliaEditorSupport/julia-vim'

function! Google(range, searchTermArg)
  let searchTerm = []

  let sel = a:range == 0 ? '' : getline("'<")[getpos("'<")[2] - 1:getpos("'>")[2] - 1]

  if sel != ''
    call add(searchTerm, sel)
  endif

  if a:searchTermArg != ''
    call add(searchTerm, a:searchTermArg)
  endif

  let escapedSearchTerm = luaeval('_A:gsub("\n", "\r\n"):gsub("([^%w])", function(c) return string.format("%%%02X", string.byte(c)) end)', join(searchTerm, ' '))
  call system("open http://www.google.fr/search?q=" . escapedSearchTerm)
endfunction

command! -nargs=* -range Google call Google(<range>, <q-args>)

" visual copy
" Option+C (macOS + Kitty)
" at the end of ~/.config/kitty/kitty.conf
" map cmd+c send_text all \x1b\x63
vnoremap <M-y> "+y

command! Code :silent execute "!code -g " . expand('%') . ":" . line(".") | :redraw!

function! NodeRelativeFilename(lines)
  let fn = substitute(tlib#file#Relative(join(a:lines), expand('%:h')), '\.[^.]*$', '', '')
  if l:fn =~ '^\.'
    return l:fn
  else
    return './' . l:fn
  endif
endfunction

vnoremap <leader>* :<c-u>call SearchOperator(visualmode())<cr>

" set the search patten to the visually highlighted text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

function! SearchOperator(type)
    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        return
    endif

    call SearchString(@@)
endfunction

function! SearchString(str)
    call histadd("cmd", "Rgs " . a:str)
    execute "Rgs " . a:str
endfunction

function! SearchRegex(str)
    call histadd("cmd", "Rg " . a:str)
    execute "Rg " . a:str
endfunction

nnoremap <silent> <Leader>v :e ~/.config/nvim/init.vim<cr>

nmap <leader>cf :let @+=expand("%")<CR>
nmap <leader>cl :let @+=expand("%").":".line(".")<CR>
nmap <leader>cF :let @+=expand("%:p")<CR>

" Plug 'neoclide/coc.nvim', {'branch': 'release'}
" let g:coc_global_extensions = ['coc-json', 'coc-html', 'coc-yaml', 'coc-emmet', 'coc-snippets']
" inoremap <silent><expr> <c-n> coc#refresh()
" set updatetime=140

" " GoTo code navigation.
" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)

Plug 'artemave/vigun'
au FileType javascript,typescript nnoremap <Leader>o :VigunMochaOnly<cr>

Plug 'w0rp/ale'
Plug 'will133/vim-dirdiff'
Plug 'nightsense/wonka'

Plug 'mattn/emmet-vim'
let g:user_emmet_settings = {
  \  'html' : {
  \    'empty_element_suffix': ' />'
  \  },
  \  'mdx' : {
  \    'extends': 'jsx',
  \  }
  \}

Plug '907th/vim-auto-save'
let g:auto_save = 1

" vim-jsbeautify
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>

Plug 'AndrewRadev/sideways.vim' " move arguments left and right
nnoremap _ :SidewaysLeft<cr>
nnoremap + :SidewaysRight<cr>

omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

Plug 'neomake/neomake'
Plug 'tpope/vim-dispatch' " for vim-test
Plug 'vim-test/vim-test'
Plug 'radenling/vim-dispatch-neovim'

nmap <leader>tf :TestFile<CR>
nmap <leader>tl :TestNearest<CR>
nmap <leader>tt :TestLast<CR>
nmap <leader>tv :TestVisit<CR>
nmap <leader>to :copen<CR>
let test#strategy = 'dispatch'

autocmd FileType qf call AdjustWindowHeight(30, 40)
function! AdjustWindowHeight(percent_full_width, percent_full_height)
  if &columns*a:percent_full_width/100 >= 100
    exe "wincmd L"
    exe (&columns*a:percent_full_width/100) . "wincmd |"
  else
    exe "wincmd J"
    exe (&lines*a:percent_full_height/100) . "wincmd _"
  endif
endfunction

call plug#end()

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
syntax on
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
set complete-=i
set nofileignorecase " make sure we use exact case on macos
set splitbelow
set splitright
set virtualedit=block " we can select beyond the end of the line in visual block, useful for vim-sandwich
set diffopt+=vertical " diffs are always shown left/right
set isfname-==
set regexpengine=1 " vim-ruby performance
set mouse=a
set inccommand=nosplit
set signcolumn=yes:1

if exists('+termguicolors')
  if exists('$TMUX')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif

  set termguicolors
endif

nnoremap <Leader>sn :set number!<CR>
nnoremap <Leader>sl :set cursorline!<CR>
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

au TabLeave * let g:lasttab = tabpagenr()

if has("win32") || has("win64")
    set directory=$TMP
else
    set shell=bash
endif


function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

nnoremap <silent> <leader>a :ArgWrap<CR>

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
" nnoremap + <C-a>
" nnoremap _ <C-x>
" CTags
"
" $PATH appears different to vim for some reason and hence wrong ctags gets picked
" until then, you need to manually override ctags in /usr/bin/ with those from homebrew
" TODO fix vim path
map <Leader>rt :!ctags --extra=+f -R *<CR><CR>

" visual select last pasted text
" http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap gp `[v`]

command! Requires execute "Ag -s \"require\\(\\s*['\\\\\\\"][^'\\\\\\\"]*" . expand('%:t:r') . "[^'\\\\\\\"]*['\\\\\\\"]\\s*\\)\""

nnoremap <silent> <Leader>d :call DiffToggle()<CR>
function! DiffToggle()
    if &diff
        diffoff
    else
        diffthis
    endif
endfunction

nnoremap <silent> <Leader>w :call DiffIgnoreWhitespaceToggle()<CR>
function! DiffIgnoreWhitespaceToggle()
   if &diffopt =~ 'iwhite'
       set diffopt-=iwhite
   else
       set diffopt+=iwhite
   endif
endfunction

if executable('ag')
  set grepprg=ag\ --vimgrep
  set grepformat=%f:%l:%c:%m
endif

autocmd FileType ruby set syntax=
autocmd FileType typescript set syntax=
nnoremap <Leader>sn :set number!<CR>
nnoremap <Leader>sl :set cursorline!<CR>
nnoremap <Leader>e :e %:h

" escaping terminal
if has('nvim')
  tnoremap <Esc> <C-\><C-n>
  tnoremap <M-[> <Esc>
  tnoremap <C-v><Esc> <Esc>
endif

" spelling
autocmd BufRead,BufNewFile *.md setlocal spell
autocmd FileType gitcommit setlocal spell
highlight SpellBad guifg=#eC6a88
highlight SpellCap guifg=#eC6a88
highlight SpellRare guifg=#eC6a88
highlight SpellLocal guifg=#eC6a88

source $HOME/.config/nvim/completion.vim
source $HOME/.config/nvim/fzf.vim
source $HOME/.config/nvim/statusline.vim
source $HOME/.config/nvim/style.vim
source $HOME/.config/nvim/snippets.vim
source $HOME/.config/nvim/vim.vim
source $HOME/.config/nvim/ale.vim
source $HOME/.config/nvim/vim-easy-align.vim
source $HOME/.config/nvim/projects.vim
source $HOME/.config/nvim/vim-surround.vim

lua << EOF
require('gitsigns').setup {
  current_line_blame = true
}
EOF
