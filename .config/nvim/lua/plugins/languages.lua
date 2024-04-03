return {
  {
    "tpope/vim-rails",
    ft = { "ruby" },
  },
  {
    "tpope/vim-cucumber",
    ft = { "cucumber" },
  },
  {
    "plasticboy/vim-markdown",
    ft = { "markdown" },

    init = function()
      vim.g.vim_markdown_folding_disabled = 1
    end,
  },
  {
    "leafgarland/typescript-vim",
    enabled = false,
    ft = { "typescript", "typescriptreact" },
  },
  {
    "maxmellon/vim-jsx-pretty",
    ft = { "javascriptreact" },
  },
  {
    "refractalize/js-toggle-async-fn.nvim",

    ft = {
      "javascriptreact",
      "javascript",
      "typescriptreact",
      "typescript",
    },

    keys = {
      {
        "<leader>ra",
        function()
          require("js_toggle_async_fn").toggle_async_function()
        end,
        desc = "Toggle a function between being async and non-async",
      },
    },
  },
  {
    "jparise/vim-graphql",
    ft = { "graphql" },
  },
  {
    "refractalize/vim-mochajs",
    ft = { "javascriptreact", "javascript" },
  },
  {
    "google/vim-jsonnet", -- jsonnet language support
    ft = { "jsonnet" },
  },
  {
    "rust-lang/rust.vim",
    ft = { "rust" },
  },
  {
    "dccsillag/magma-nvim",
    build = ":UpdateRemotePlugins",

    -- cmd = "MagmaInit",

    keys = {
      { "<leader>me", "<cmd>MagmaEvaluateLine<CR>", desc = "Evaluate the current line." },
      { "<leader>me", "<cmd>MagmaEvaluateVisual<CR>", desc = "Evaluate the selected text.", mode = "v" },
      { "<leader>mc", "<cmd>MagmaEvaluateOperator<CR>", desc = "Reevaluate the currently selected cell." },
      { "<leader>mr", "<cmd>MagmaRestart!<CR>", desc = "Shuts down and restarts the current kernel." },
      {
        "<leader>mx",
        "<cmd>MagmaInterrupt<CR>",
        desc = "Interrupts the currently running cell and does nothing if not cell is running.",
      },
    },

    config = function()
      vim.g.magma_image_provider = "kitty"
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = "cd app && npm install",
    config = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
}
