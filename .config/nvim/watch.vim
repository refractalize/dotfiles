function! ShellComplete(ArgLead, CmdLine, CursorPos)
  let currentWatch = luaeval("require('watch').current()")

  let cmd = currentWatch isnot v:null ? [currentWatch['cmd']] : []

  return cmd + getcompletion(a:ArgLead, 'shellcmd') + getcompletion(a:ArgLead, 'file')
endfunction

command! -bang -nargs=+ -complete=customlist,ShellComplete Watch lua require('watch').start(<q-args>, { stdin = '<bang>' == '!' })
command! -nargs=* -complete=customlist,ShellComplete WatchEdit lua require('watch').edit(<q-args>)
command! WatchSetStdin lua require('watch').set_stdin()
command! WatchUnsetStdin lua require('watch').unset_stdin()
command! WatchStop lua require('watch').stop()
command! WatchInfo lua require('watch').info()
command! -nargs=1 -complete=buffer WatchAttach lua require('watch').attach(<f-args>)
command! WatchDetach lua require('watch').detach()
