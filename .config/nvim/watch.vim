function! ShellComplete(ArgLead, CmdLine, CursorPos)
  return getcompletion(a:ArgLead, 'shellcmd') + getcompletion(a:ArgLead, 'file')
endfunction

command! -bang -nargs=+ -complete=customlist,ShellComplete Watch lua require('watch').start(<q-args>, '<bang>' == '!')
command! WatchStop lua require('watch').stop()
command! WatchInfo lua require('watch').info()
command! -nargs=1 -complete=buffer WatchAttach lua require('watch').attach(<q-args>)
command! WatchDetach lua require('watch').detach()
