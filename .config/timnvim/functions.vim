function SortPositions(p1, p2)
  if a:p1[0] < a:p2[0]
    return -1
  elseif a:p1[0] > a:p2[0]
    return 1
  else
    if a:p1[1] < a:p2[1]
      return -1
    elseif a:p1[1] > a:p2[1]
      return 1
    else
      return 0
    endif
  endif
endfunction

function GetCharWiseText(p1, p2)
  let range = sort([getpos(a:p1)[1:2], getpos(a:p2)[1:2]], { p1, p2 -> SortPositions(p1, p2) })
  let lines = getline(range[0][0], range[1][0])

  if len(lines) ==# 1
    let from = range[0][1] - 1
    let to = range[1][1] - 1
    return lines[0][from:to]
  else
    let lines[0] = lines[0][range[0][1] - 1:-1]
    let lines[-1] = lines[-1][0:range[1][1] - 1]
    return join(lines, "\n")
  endif
endfunction

function GetBlockWiseText(p1, p2)
  let range = sort([getpos(a:p1)[1:2], getpos(a:p2)[1:2]], { p1, p2 -> SortPositions(p1, p2) })
  let lines = getline(range[0][0], range[1][0])

  return join(map(lines, { i, line -> line[range[0][1]-1:range[1][1]-1] }), "\n")
endfunction

function GetLineWiseText(p1, p2)
  let lines = getline(a:p1, a:p2)
  return join(lines, "\n")
endfunction

function! GetVisualText(range)
  let m = mode()

  if m ==# 'n' && a:range
    let m = visualmode()

    if m ==# 'V'
      return GetLineWiseText("'<", "'>")
    elseif m ==# 'v'
      return GetCharWiseText("'<", "'>")
    elseif m ==# ''
      return GetBlockWiseText("'<", "'>")
    endif
  elseif m ==# 'v'
    if m ==# 'V'
      return GetLineWiseText("v", ".")
    elseif m ==# 'v'
      return GetCharWiseText("v", ".")
    elseif m ==# ''
      return GetBlockWiseText("v", ".")
    endif
  elseif m ==# 'i'
    return getreg('"')
  endif
endfunction
