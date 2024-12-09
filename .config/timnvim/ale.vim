let g:ale_sign_column_always = 1
let g:ale_sign_error = '🤬'
let g:ale_sign_warning = '🤔'
let g:ale_lint_delay = 1000
let g:ale_linters_explicit = 0
let g:airline#extensions#ale#enabled = 1

" highlight link ALEErrorSign ErrorMsg
" highlight link ALEWarningSign WarningMsg
highlight ALEError cterm=undercurl gui=undercurl
highlight ALEWarning cterm=undercurl gui=undercurl
" highlight LspDiagnosticsDefaultError gui=italic
" highlight LspDiagnosticsDefaultWarning gui=italic
" highlight LspDiagnosticsUnderlineError gui=italic guibg=#3B4048
" highlight LspDiagnosticsUnderlineWarning gui=italic guibg=#3B4048
highlight clear ALEVirtualTextError
highlight link ALEVirtualTextError TypeDef
highlight clear ALEVirtualTextWarning
highlight link ALEVirtualTextWarning TypeDef
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = "    ⊘    "
let g:ale_history_log_output = 1
let g:ale_fixers = {
\ 'javascript': [
\   'prettier',
\   'eslint'
\ ],
\ 'javascriptreact': [
\   'prettier',
\   'eslint'
\ ],
\ 'ruby': [
\   'rubocop'
\ ],
\ 'sql': [
\   'pgformatter'
\ ],
\ 'json': [
\   'jq'
\ ],
\ 'xml': [
\   'xmllint'
\ ],
\}
let g:ale_linters = {
\  'rust': ['cargo', 'analyzer'],
\  'javascript': ['eslint'],
\  'javascriptreact': ['eslint']
\}

let g:ale_rust_cargo_check_tests = 1
nnoremap <silent> [l :ALEPrevious<CR>
nnoremap <silent> ]l :ALENext<CR>
nnoremap <M-f> :ALEFix<CR>
