" cmd-c and cmd-v
"
" insert these in kitty.conf:
"
" map cmd+c kitten send_to_vim.py copy alt+y
" map cmd+v kitten send_to_vim.py paste alt+p
vnoremap <M-y> "+y
nnoremap <M-p> "+p
inoremap <M-p> <C-R>+
cnoremap <M-p> <C-R>+
tnoremap <M-p> <C-\><C-N>"+pi
