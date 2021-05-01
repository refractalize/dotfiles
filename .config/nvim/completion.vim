lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"ruby", "typescript"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true              -- false will disable the whole extension
  }
}
EOF

lua << EOF
require'lspconfig'.solargraph.setup{on_attach=require'completion'.on_attach}
EOF
lua vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end

" lua require'lspconfig'.tsserver.setup{on_attach=require'completion'.on_attach}
" let g:completion_matching_strategy_list = ['fuzzy', 'exact', 'substring', 'all']

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

call deoplete#custom#option('auto_complete_popup', 'manual')
inoremap <silent><expr> <C-N> deoplete#complete()

" nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
" nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
" nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
" nnoremap <silent> <c-K> <cmd>lua vim.lsp.buf.signature_help()<CR>
" nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
" nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
" nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
" nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
