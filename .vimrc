nnoremap <space> <Nop>
let mapleader=" "

set nocompatible               " be iMproved
filetype off                   " required!

call plug#begin('~/.vim/plugged')

Plug 'tomasr/molokai'
Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'joshdick/onedark.vim'
Plug 'ntk148v/vim-horizon'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive' " git commands
Plug 'tpope/vim-rhubarb' " github helpers for vim-fugitive
Plug 'groenewege/vim-less'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-abolish'
Plug 'featurist/vim-pogoscript'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-surround' " add/remove/change quotes, parens
Plug 'tpope/vim-rails'
Plug 'sjl/gundo.vim' " super undo
Plug 'tpope/vim-cucumber'
Plug 'godlygeek/tabular' " format tables of data
Plug 'michaeljsmith/vim-indent-object' " treat indented sections of code as vim objects
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'pangloss/vim-javascript'
Plug 'vim-scripts/summerfruit256.vim'
Plug 'maksimr/vim-jsbeautify'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'Chiel92/vim-autoformat'
Plug 'nvim-lua/completion-nvim'
Plug 'direnv/direnv.vim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

let g:airline_powerline_fonts = 1
let g:airline_section_a = ''
let g:airline_section_b = ''
let g:airline_theme = 'onedark'

Plug 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

autocmd FileType javascriptreact UltiSnipsAddFiletypes javascript
autocmd FileType typescript UltiSnipsAddFiletypes javascript
autocmd FileType typescriptreact UltiSnipsAddFiletypes javascript

" vim thin | cursor for insert
if !has('nvim')
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
endif

Plug 'tpope/vim-unimpaired' " [c ]c ]l [l etc, for navigating git changes, lint errors, search results, etc
Plug 'tpope/vim-eunuch' " file unix commands, :Delete, :Move, etc
Plug 'tpope/vim-jdaddy' " JSON manipulation
Plug 'tpope/vim-commentary' " make lines comments or not
Plug 'tpope/vim-repeat' " repeat complex commands with .
Plug 'moll/vim-node'
Plug 'Shougo/neomru.vim' " for fzf mru
Plug 'FooSoft/vim-argwrap' " expanding and collapsing lists
Plug 'google/vim-jsonnet' " jsonnet language support
Plug 'szw/vim-g'

" json and jsonl support
Plug 'elzr/vim-json' 
let g:vim_json_syntax_conceal = 0

Plug 'vim-scripts/indentpython.vim'

Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'
Plug 'JuliaEditorSupport/julia-vim'

" visual copy
" Option+C (macOS + Kitty)
" at the end of ~/.config/kitty/kitty.conf
" map cmd+c send_text all \x1b\x63
vnoremap <M-y> "+y

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
let $FZF_DEFAULT_OPTS .= ' --exact'
let g:fzf_layout = { 'down': '~40%' }

function! Mru(onlyLocal)
  if a:onlyLocal
    let grep = 'grep ^' . getcwd() . ' |'
  else
    let grep = ''
  endif

  call fzf#run(fzf#wrap('mru', {
    \ 'source': '(sed "1d" $HOME/.cache/neomru/file | ' . l:grep .  ' sed s:' . getcwd() . '/:: && rg --files --hidden) | awk ''!cnts[$0]++''',
    \ 'options': ['--no-sort', '--prompt', a:onlyLocal ? 'mru> ' : 'mru-all> ', '--tiebreak', 'end']
    \ }))
endfunction

command! -bang Mru :call Mru(!<bang>0)
command! -bar -bang Mapsv call fzf#vim#maps("x", <bang>0)
command! -bar -bang Mapsi call fzf#vim#maps("i", <bang>0)
command! -bar -bang Mapso call fzf#vim#maps("o", <bang>0)
command! Code :silent execute "!code -g " . expand('%') . ":" . line(".") | :redraw!

nnoremap <silent> <Leader><Leader> :Mru<cr>
nnoremap <silent> <Leader>f :Mru!<cr>

let g:fzf_history_dir = '~/.fzf-history'

let g:fzf_action = {
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'
  \ }

imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-l> <plug>(fzf-complete-buffer)
imap <c-x><c-b> <plug>(fzf-complete-buffer-line)

function! NodeRelativeFilename(lines)
  let fn = substitute(tlib#file#Relative(join(a:lines), expand('%:h')), '\.[^.]*$', '', '')
  if l:fn =~ '^\.'
    return l:fn
  else
    return './' . l:fn
  endif
endfunction

inoremap <expr> <c-x><c-j> fzf#vim#complete(fzf#wrap({
  \ 'reducer': function('NodeRelativeFilename'),
  \ 'source': 'rg --files --hidden',
  \ }))

nnoremap <silent> <Leader>* :call SearchRegex("\\b" . expand('<cword>') .  "\\b")<cr>

nnoremap <leader>G :Rg 
nnoremap <leader>g :Rg<cr>
nnoremap <leader>l :BLines<cr>
command! -bang -nargs=* Rgs call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case --fixed-strings -- ".shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)

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

nnoremap <silent> <Leader>v :e ~/.vimrc<cr>

nmap <leader>cf :let @+=expand("%")<CR>
nmap <leader>cl :let @+=expand("%").":".line(".")<CR>
nmap <leader>cF :let @+=expand("%:p")<CR>

Plug 'neoclide/coc.nvim', {'branch': 'release'}
" let g:coc_global_extensions = ['coc-json', 'coc-html', 'coc-yaml', 'coc-emmet', 'coc-snippets']
inoremap <silent><expr> <c-n> coc#refresh()
" set updatetime=140

" " GoTo code navigation.
" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)

Plug 'artemave/vigun'
au FileType javascript nnoremap <Leader>o :VigunMochaOnly<cr>

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

Plug 'airblade/vim-gitgutter'
nmap <Leader>ha <Plug>GitGutterStageHunk
nmap <Leader>hr <Plug>GitGutterUndoHunk
nmap <Leader>hv <Plug>GitGutterPreviewHunk
let g:gitgutter_preview_win_floating = 1

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
set background=dark
set cursorline
colorscheme horizon
highlight DiffText term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#000000
highlight DiffChange term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#484540 gui=NONE
highlight DiffDelete gui=NONE guibg=#1e2127 guifg=#5f3a41
highlight DiffAdd gui=NONE guifg=NONE guibg=#3b453f
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
set diffopt+=vertical
set isfname-==
set regexpengine=1 " vim-ruby performance
set mouse=nvi

" italic
highlight Comment gui=italic

if exists('+termguicolors')
  if exists('$TMUX')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif

  set termguicolors
endif

if !has('nvim')
  let &t_ZH="\e[3m"
  let &t_ZR="\e[23m"
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

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <silent> <C-W><C-J> :exe "resize +5"<CR>
nnoremap <silent> <C-W><C-K> :exe "resize -5"<CR>
nnoremap <silent> <C-W><C-L> :exe "vertical resize +10"<CR>
nnoremap <silent> <C-W><C-H> :exe "vertical resize -10"<CR>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>

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

au TabLeave * let g:lasttab = tabpagenr()

imap <c-x><c-f> <plug>(fzf-complete-path)

if has("win32") || has("win64")
    set directory=$TMP
else
    set shell=bash
endif

" guicursor=n-v-c:block,o:hor50,i-ci:hor15,r-cr:hor30,sm:block

let g:ale_sign_column_always = 1
let g:ale_sign_error = '🤬'
let g:ale_sign_warning = '🤔'
let g:ale_lint_delay = 1000
let g:ale_linters_explicit = 0
highlight link ALEErrorSign ErrorMsg
highlight link ALEWarningSign WarningMsg
highlight ALEError gui=italic guibg=#3B4048
highlight ALEWarning gui=italic guibg=#3B4048
let g:ale_history_log_output = 1
let g:ale_fixers = {
\ 'javascript': [
\   'prettier',
\   'eslint'
\ ],
\ 'ruby': [
\   'rubocop'
\ ],
\}
let g:ale_linters = {
\  'rust': ['cargo'],
\  'javascript': ['eslint'],
\  'javascriptreact': ['eslint']
\}
nnoremap <silent> [l :ALEPrevious<CR>
nnoremap <silent> ]l :ALENext<CR>

function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

function! FixJsFormatting()
  let command = 'eslint'
  if executable('standard')
    let command = 'standard'
  endif
  silent let f = system(command.' --fix '.expand('%'))
  checktime
endfunction
autocmd FileType {javascript,javascript.jsx} nnoremap <Leader>p :call FixJsFormatting()<cr>

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

fun! JsRequireComplete(findstart, base)
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let end = col('.') - 1
    let start = end
    while start > 0 && line[start - 1] =~ "[^'\"]"
      let start -= 1
    endwhile

    let base = substitute(line[start : end - 1], '^[./]*', '', '')
    let cmd = 'ag --nogroup --nocolor --hidden -i -g "'.base.'"'

    let g:js_require_complete_matches = map(
          \ systemlist(cmd),
          \ {i, val -> substitute(val, '\(index\)\?.jsx\?$', '', '')}
          \ )

    return start
  else
    " find files matching with "a:base"
    let res = []
    let search_path = substitute(expand('%:h'), '[^/.]\+', '..', 'g')
    for m in g:js_require_complete_matches
      if m =~ substitute(a:base, '^[./]*', '', '')
        if search_path != ''
          call add(res, search_path.'/'.m)
        else
          call add(res, m)
        endif
      endif
    endfor
    return res
  endif
endfun
autocmd FileType {javascript,javascript.jsx} setlocal completefunc=JsRequireComplete

autocmd FileType rust set shiftwidth=2
" autocmd FileType ruby setlocal nonumber " very slow in ruby when editing
nnoremap <Leader>n :set number!<CR>
nnoremap <Leader>l :set cursorline!<CR>
nnoremap <Leader>e :e %:h
