command! -nargs=1 -complete=customlist,theme#CompleteTheme Theme call theme#SetTheme(<f-args>)
command! -nargs=1 -complete=customlist,theme#CompleteTheme ThemeEdit call theme#EditTheme(<f-args>)
command! -nargs=* -complete=customlist,theme#CompleteTheme ThemeAlias call theme#AliasTheme(<f-args>)

" if v:vim_did_enter
"  call theme#SetupCurrentTheme()
" else
"  autocmd VimEnter * call theme#SetupCurrentTheme()
" endif
