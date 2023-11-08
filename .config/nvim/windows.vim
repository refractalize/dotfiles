nnoremap <M-j> <C-W>j
nnoremap <M-k> <C-W>k
nnoremap <M-l> <C-W>l
nnoremap <M-h> <C-W>h
nnoremap <M-;> <C-W>p
nnoremap <M-r> <C-W>r
nnoremap <M-x> <C-W>x
nnoremap <M-R> <C-W>R
nnoremap <M-s> <Cmd>split<CR>
nnoremap <M-v> <Cmd>vsplit<CR>
nnoremap <M-o> <C-W>o
nnoremap <M-=> <C-W>=
tnoremap <M-T> <C-\><C-N><C-W>Ti
nnoremap <M-w> <C-W>c

nnoremap <M-J> <Cmd>resize -2<CR>
nnoremap <M-K> <Cmd>resize +2<CR>
nnoremap <M-L> <Cmd>vertical resize +2<CR>
nnoremap <M-H> <Cmd>vertical resize -2<CR>

nnoremap <M-,> <Cmd>wincmd R<CR>
nnoremap <M-.> <Cmd>wincmd r<CR>

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
