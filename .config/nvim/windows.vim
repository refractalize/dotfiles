nnoremap <M-j> <C-W>j
nnoremap <M-k> <C-W>k
nnoremap <M-l> <C-W>l
nnoremap <M-h> <C-W>h
nnoremap <M-;> <C-W>p
nnoremap <M-r> <C-W>r
nnoremap <M-x> <C-W>x
nnoremap <M-R> <C-W>R
nnoremap <silent> <M-s> :rightbelow horizontal split<CR>
nnoremap <silent> <M-v> :rightbelow vertical split<CR>
nnoremap <M-o> <C-W>o
nnoremap <M-=> <C-W>=
tnoremap <M-T> <C-\><C-N><C-W>Ti
nnoremap <M-w> <C-W>c

nnoremap <silent> <M-J> :exe "resize -2"<CR>
nnoremap <silent> <M-K> :exe "resize +2"<CR>
nnoremap <silent> <M-L> :exe "vertical resize +2"<CR>
nnoremap <silent> <M-H> :exe "vertical resize -2"<CR>

lua <<LUA
  local id = vim.api.nvim_create_augroup("CursorLine", {})
  vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "WinEnter"}, {
    group = id,
    callback = function()
      vim.wo.cursorline = true
    end
  })
  vim.api.nvim_create_autocmd({"WinLeave"}, {
    group = id,
    callback = function()
      if vim.bo.filetype ~= 'neo-tree' then
        vim.wo.cursorline = false
      end
    end
  })
LUA
