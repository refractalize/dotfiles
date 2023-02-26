return {
  {
    'tpope/vim-rails',
    ft = { 'ruby' },
  },
  {
  'tpope/vim-cucumber',
    ft = { 'cucumber' },
  },
  {
    'plasticboy/vim-markdown',
    ft: { 'markdown' },
  },
  {
    'leafgarland/typescript-vim',
    ft: { 'typescript', 'typescriptreact' },
  },
  {
    'maxmellon/vim-jsx-pretty',
    ft: { 'javascriptreact' },
  },
  {
    'jparise/vim-graphql',
    ft: { 'graphql' },
  },
  {
    'tapayne88/vim-mochajs',
    ft: { 'javascriptreact', 'javascript' },
  },
  {
    'google/vim-jsonnet', -- jsonnet language support
    ft: { 'jsonnet' },
  },
  'jxnblk/vim-mdx-js',
  {
    'rust-lang/rust.vim',
    ft: { 'rust' },
  },
  {
    'JuliaEditorSupport/julia-vim',

    ft = { 'julia' },

    config = function()
      vim.g.latex_to_unicode_tab = "off"
    end
  },
}
