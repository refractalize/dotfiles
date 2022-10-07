function! ShellComplete(ArgLead, CmdLine, CursorPos)
  let currentWatch = luaeval("require('watch').current()")

  let cmd = currentWatch isnot v:null ? [currentWatch['cmd']] : []

  return cmd + getcompletion(a:ArgLead, 'shellcmd') + getcompletion(a:ArgLead, 'file')
endfunction

function! SubstituteCommand(cmd, fn)
  return substitute(a:cmd, '\\\?{\(\(\d*\)\|\(new\(\:\(\i\+\)\)\?\)\)}', a:fn, 'g')
endfunction

function! RenderCommandWithArguments(cmd)
  return SubstituteCommand(a:cmd, { m -> ReplacePlaceholder(m[0], m[2]) })
endfunction

function! ResolveCommandArgumentBuffers(cmd, current_buf, new_buffers)
  return SubstituteCommand(a:cmd, { m -> ResolveCommandArgumentBuffer(m[0], m[2], m[3], a:current_buf, a:new_buffers) })
endfunction

function! FindCommandArgumentBuffers(cmd)
  let buffers = []
  call SubstituteCommand(a:cmd, { m -> FindCommandArgumentBuffer(m[2], m[3], m[5], buffers) })
  return buffers
endfunction

function! FindCommandArgumentBuffer(bufferNumber, bufferNew, bufferNewFileType, buffers)
  if a:bufferNumber !=# ''
    call add(a:buffers, str2nr(a:bufferNumber))
  elseif a:bufferNew !=# ''
    call add(a:buffers, a:bufferNewFileType)
  endif
endfunction

function! ResolveCommandArgumentBuffer(placeholderText, bufferNumber, bufferNew, current_buf, new_buffers)
  if a:placeholderText == '\{}'
    return '{}'
  elseif a:bufferNew !=# ''
    let buffer = remove(a:new_buffers, 0)
    return '{' . buffer . '}'
  elseif a:bufferNumber !=# ''
    return '{' . a:bufferNumber . '}'
  elseif !a:bufferNumber
    return '{' . a:current_buf . '}'
  endif
endfunction

function! ReplacePlaceholder(placeholderText, bufferNumber)
  if a:placeholderText == '\{}'
    return '{}'
  else
    return shellescape(join(getbufline(str2nr(a:bufferNumber), 1,'$'), "\n"))
  endif
endfunction

command! -bang -nargs=+ -complete=customlist,ShellComplete Watch lua require('watch').start(<q-args>, { stdin = '<bang>' == '!' })
command! -nargs=* -complete=customlist,ShellComplete WatchEdit lua require('watch').edit(<q-args>)
command! WatchSetStdin lua require('watch').set_stdin()
command! WatchUnsetStdin lua require('watch').unset_stdin()
command! WatchStop lua require('watch').stop()
command! WatchInfo lua require('watch').info()
command! -nargs=1 -complete=buffer WatchAttach lua require('watch').attach(<f-args>)
command! WatchDetach lua require('watch').detach()
