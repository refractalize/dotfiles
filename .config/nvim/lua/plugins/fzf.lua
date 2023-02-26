return {
  { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
  'junegunn/fzf.vim',

  {
    'refractalize/fzf-mru',
    dev = true,
  },

  {
    'refractalize/fzf-git',
    dev = true,
  }
}
