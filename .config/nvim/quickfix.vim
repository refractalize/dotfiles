function! FormatQuickFixLine(item)
  if a:item.bufnr > 0
    return fnamemodify(bufname(a:item.bufnr), ':p:.') . '|' . a:item.lnum . '|' . a:item.text
  else
    return a:item.text
  endif
endfunction

function! FormatQuickFix(info)
  let items = getqflist({'id' : a:info.id, 'items' : 1}).items
  return map(range(a:info.start_idx - 1, a:info.end_idx - 1), { idx -> FormatQuickFixLine(items[idx]) })
endfunction

set quickfixtextfunc=FormatQuickFix

autocmd FileType qf syntax match Normal /^||/ conceal | set concealcursor=nc | set conceallevel=2
