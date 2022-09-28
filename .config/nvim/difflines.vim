command! -range DiffLines :lua require('difflines').select_range(<range>, <line1>, <line2>)<cr>
command! DiffLinesReset :lua require('difflines').reset_range()<cr>
