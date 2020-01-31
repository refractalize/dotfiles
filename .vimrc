nnoremap <space> <Nop>
let mapleader=" "

set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle
" required!
Plugin 'VundleVim/Vundle.vim'

Plugin 'tomasr/molokai'
Plugin 'sickill/vim-monokai'
Plugin 'tpope/vim-vinegar'
" Plugin 'justinmk/vim-dirvish'
Plugin 'altercation/vim-colors-solarized'
Plugin 'lifepillar/vim-solarized8'
Plugin 'tpope/vim-fugitive' " git commands
Plugin 'tpope/vim-rhubarb' " github helpers for vim-fugitive
Plugin 'groenewege/vim-less'
Plugin 'tpope/vim-markdown'
Plugin 'featurist/vim-pogoscript'
Plugin 'tpope/vim-rails'
Plugin 'machakann/vim-sandwich'
Plugin 'VimClojure'
Plugin 'sjl/gundo.vim' " super undo
Plugin 'tpope/vim-cucumber'
Plugin 'godlygeek/tabular' " format tables of data
Plugin 'michaeljsmith/vim-indent-object' " treat indented sections of code as vim objects
Plugin 'leafgarland/typescript-vim'
Plugin 'maxmellon/vim-jsx-pretty'
Plugin 'pangloss/vim-javascript'
Plugin 'vim-scripts/summerfruit256.vim'
Plugin 'maksimr/vim-jsbeautify'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'

Plugin 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

autocmd FileType typescript UltiSnipsAddFiletypes javascript
autocmd FileType typescriptreact UltiSnipsAddFiletypes javascript

Plugin 'tpope/vim-unimpaired' " [c ]c ]l [l etc, for navigating git changes, lint errors, search results, etc
Plugin 'tpope/vim-eunuch' " file unix commands, :Delete, :Move, etc
Plugin 'tpope/vim-jdaddy' " JSON manipulation
Plugin 'tpope/vim-commentary' " make lines comments or not
Plugin 'tpope/vim-repeat' " repeat complex commands with .
Plugin 'moll/vim-node'
Plugin 'Shougo/neomru.vim' " for fzf mru
Plugin 'FooSoft/vim-argwrap' " expanding and collapsing lists
Plugin 'google/vim-jsonnet' " jsonnet language support

Plugin 'rust-lang/rust.vim' " jsonnet language support

" fzf
set rtp+=/usr/local/opt/fzf
Plugin 'junegunn/fzf.vim'
let $FZF_DEFAULT_OPTS .= ' --exact'

function! Mru(onlyLocal)
  if a:onlyLocal
    let grep = 'grep ^' . getcwd() . ' |'
  else
    let grep = ''
  endif

  call fzf#run(fzf#wrap('mru', {
    \ 'source': '(sed "1d" $HOME/.cache/neomru/file | ' . l:grep .  ' sed s:' . getcwd() . '/:: && rg --files --hidden) | awk ''!cnts[$0]++''',
    \ 'options': '--no-sort --prompt "mru> "'
    \ }))
endfunction

command -bang Mru :call Mru(!<bang>0)

nnoremap <silent> <Leader><Leader> :Mru<cr>
nnoremap <silent> <Leader>f :Mru!<cr>

let g:fzf_history_dir = '~/.fzf-history'

let g:fzf_action = {
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'
  \ }

imap <c-x><c-k> <plug>(fzf-complete-word)

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

nnoremap <silent> <Leader>* :execute 'Rg' "\\b" . expand('<cword>') . "\\b"<CR>
nnoremap <leader>G :Rg 

nnoremap <leader>g :set operatorfunc=SearchOperator<cr>g@
vnoremap <leader>g :<c-u>call SearchOperator(visualmode())<cr>

function! SearchOperator(type)
    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        return
    endif

    execute "Rg " . @@
endfunction

nnoremap <silent> <Leader>v :e $MYVIMRC<cr>

" Plugin 'neoclide/coc.nvim'

" autocmd FileType unite let b:coc_suggest_disable = 1
" inoremap <silent><expr> <c-n> coc#refresh()
" set updatetime=140

Plugin 'artemave/vigun'
au FileType javascript nnoremap <Leader>o :VigunMochaOnly<cr>

Plugin 'w0rp/ale'
Plugin 'will133/vim-dirdiff'
Plugin 'nightsense/wonka'

Plugin 'mattn/emmet-vim'
let g:user_emmet_settings = {
  \  'html' : {
  \    'empty_element_suffix': ' />'
  \  },
  \  'jsx' : {
  \    'extends': 'html',
  \    'attribute_name': {'class': 'class'},
  \  }
  \}

Plugin '907th/vim-auto-save'
let g:auto_save = 1

" vim-jsbeautify
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>

Plugin 'airblade/vim-gitgutter'
nmap <Leader>ha <Plug>GitGutterStageHunk
nmap <Leader>hr <Plug>GitGutterUndoHunk
nmap <Leader>hv <Plug>GitGutterPreviewHunk
let g:gitgutter_preview_win_floating = 1

Plugin 'AndrewRadev/sideways.vim' " move arguments left and right
nnoremap <c-h> :SidewaysLeft<cr>
nnoremap <c-l> :SidewaysRight<cr>

omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

let g:solarized_termtrans = 1
let g:solarized_old_cursor_style=1

call vundle#end()

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
highlight clear CursorLine
colorscheme molokai
let g:rehash256 = 1
highlight CursorLine ctermbg=235
highlight clear MatchParen
highlight MatchParen cterm=bold,underline gui=bold,underline
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
set complete-=i
set nofileignorecase " make sure we use exact case on macos
set splitbelow
set splitright
set virtualedit=block " we can select beyond the end of the line in visual block, useful for vim-sandwich
set diffopt+=vertical

" navigate long, wrapping lines
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
vnoremap <expr> k v:count == 0 ? 'gk' : 'k'
vnoremap <expr> j v:count == 0 ? 'gj' : 'j'

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

imap <c-x><c-f> <plug>(fzf-complete-path)

if has("win32") || has("win64")
    set directory=$TMP
else
    set shell=bash
endif

" guicursor=n-v-c:block,o:hor50,i-ci:hor15,r-cr:hor30,sm:block

if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
else
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
endif

let g:ale_sign_column_always = 1
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '∆'
let g:ale_lint_delay = 1000
let g:ale_linters_explicit = 0
highlight ALEErrorSign ctermfg=196 guifg=#ff0000
highlight ALEWarningSign ctermfg=226 guifg=#ffff00
let g:ale_history_log_output = 1
let g:ale_fixers = {'javascript': ['prettier', 'eslint']}
let g:ale_linters = {'rust': ['cargo']}

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

command! Requires execute "Ag -s \"require\\(\\s*['\\\\\\\"][^'\\\\\\\"]*" . expand('%:t:r') . "[^'\\\\\\\"]*['\\\\\\\"]\\s*\\)\""

nnoremap <silent> <Leader>d :call DiffToggle()<CR>
function! DiffToggle()
    if &diff
        diffoff
    else
        diffthis
    endif
endfunction

nnoremap <silent> <Leader>s :call DiffIgnoreWhitespaceToggle()<CR>
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

function! JsRequires()
  let grep_term = "require(.*)"
  execute 'silent grep!' "'".grep_term."'"
  redraw!

  let results = getqflist()
  call setqflist([])

  for require in results
    let match = matchlist(require.text, "'".'\(\.\.\?\/.*\)'."'")
    if len(match) > 0
      let module_path = match[1]
      let module_path_with_explicit_index = ''

      if match(module_path, '\.$') != -1
        let module_path = module_path . '/index'
      elseif match(module_path, '\/$') != -1
        let module_path = module_path . 'index'
      elseif match(module_path, 'index\(\.jsx\?\)\?$') == -1
        let module_path_with_explicit_index = module_path . '/index'
      endif

      let module_base = fnamemodify(bufname(require.bufnr), ':p:h')

      let current_file_full_path = expand('%:p:r')
      let module_full_path = fnamemodify(module_base . '/' . module_path, ':p:r')
      let module_full_path_with_explicit_index = fnamemodify(module_base . '/' . module_path_with_explicit_index, ':p:r')

      if module_full_path == current_file_full_path || module_full_path_with_explicit_index == current_file_full_path
        caddexpr bufname(require.bufnr) . ':' . require.lnum . ':' .require.text
      endif
    endif
  endfor
  copen
endfunction
autocmd FileType {javascript,javascript.jsx} nnoremap <leader>R :call JsRequires()<cr>

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
