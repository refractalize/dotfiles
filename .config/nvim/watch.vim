function! ShellComplete(ArgLead, CmdLine, CursorPos)
  return getcompletion(a:ArgLead, 'shellcmd') + getcompletion(a:ArgLead, 'file')
endfunction

function! SubstituteCommand(cmd, source_buf)
  return substitute(a:cmd, '\\\?{\(\d*\)}', { m -> m[0] == '\{}' ? '{}' : shellescape(join(getbufline(m[1] ? str2nr(m[1]) : a:source_buf, 1,'$'), "\n")) }, 'g')
endfunction

command! -bang -nargs=+ -complete=customlist,ShellComplete Watch lua require('watch').start(<q-args>, '<bang>' == '!')
command! WatchStop lua require('watch').stop()
command! WatchInfo lua require('watch').info()
command! -nargs=1 -complete=buffer WatchAttach lua require('watch').attach(<f-args>)
command! WatchDetach lua require('watch').detach()
