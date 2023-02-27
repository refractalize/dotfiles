return {
  { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
  'junegunn/fzf.vim',

  {
    'refractalize/fzf-mru',
  },

  {
    'refractalize/fzf-git',
  }
}
