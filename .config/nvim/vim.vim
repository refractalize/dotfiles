" vim thin | cursor for insert
if !has('nvim')
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
endif

" italics
if !has('nvim')
  let &t_ZH="\e[3m"
  let &t_ZR="\e[23m"
endif
