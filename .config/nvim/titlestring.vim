function! GetGitDir()
    if !exists('b:git_dir')
        let b:git_dir = system('git rev-parse --git-dir')
        if !v:shell_error
            let b:git_dir = fnamemodify(split(b:git_dir, "\n")[0], ':p')
        endif
    endif
    return b:git_dir
endfunction

function! GitBranch()
    let git_dir = GetGitDir()

    if strlen(git_dir) && filereadable(git_dir . '/HEAD')
        let lines = readfile(git_dir . '/HEAD')
        return len(lines) ? matchstr(lines[0], '[^/]*$') : ''
    else
        return ''
    endif
endfunction

function! TitleString()
  let branch = GitBranch()
  let dir = $PROMPT_ICON != "" ? $PROMPT_ICON : fnamemodify(getcwd(),':t')
  if branch == ""
    return dir
  else
    return dir . " (" . branch . ")"
  endif
endfunction

set title
set titlestring=%{TitleString()}
