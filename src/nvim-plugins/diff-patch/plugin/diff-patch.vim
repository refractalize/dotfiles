command! -nargs=0 -range DiffPatch lua require('diff-patch').diff_patch(require('utils').getRangeLines(<range>, <line1>, <line2>))
