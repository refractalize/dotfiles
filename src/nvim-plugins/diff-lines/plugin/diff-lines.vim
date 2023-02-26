command! -range DiffLines :lua require('diff-lines').select_range(<range>, <line1>, <line2>)<cr>
command! DiffLinesReset :lua require('diff-lines').reset_range()<cr>
