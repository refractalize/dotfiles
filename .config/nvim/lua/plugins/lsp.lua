return {
  {
    'neovim/nvim-lspconfig',

    dependencies = {
      'lsp-status.nvim',
      'nvim-cmp',
      'vim-matchup',
    },

    config = function()
      local lspconfig = require('lspconfig')
      local lsp_status = require'lsp-status'

      vim.cmd([[
        sign define DiagnosticSignError text=🤬
        sign define DiagnosticSignWarn text=🤔
        sign define DiagnosticSignInfo text=🤓
        sign define DiagnosticSignHint text=🤓
      ]])

      local opts = {
        noremap=true,
        silent=true
      }
      vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

      lsp_status.register_progress()

      local setup_lsp_mappings = function(
        client,
        bufnr,
        server_mappings
      )
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

        if server_mappings.format then
          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<M-f>', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts)
          end

          if client.server_capabilities.documentRangeFormattingProvider then
            vim.api.nvim_buf_set_keymap(bufnr, 'x', '<M-f>', '<cmd>lua vim.lsp.buf.range_formatting({})<CR>', opts)
          end
        end

        if server_mappings.setup then
          server_mappings.setup(client, bufnr)
        end
      end

      local servers = {
        'cssls',
        'html',
        'jsonls',
        'julials',
        rust_analyzer = {
          ["rust-analyzer"] = {
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
            cargo = {
              buildScripts = {
                enable = true,
              },
            },
            procMacro = {
              enable = true
            },
          }
        },
        'solargraph',
        'sqls',
        tsserver = {
          mappings = {
            format = false
          }
        },
        eslint = {
          format = true,
          mappings = {
            format = false,
            setup = function(client, bufnr)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<M-F>', '<cmd>EslintFixAll<CR>', opts)
            end,
          }
        },
        'yamlls',
      }

      local capabilities = vim.tbl_extend('keep', {}, lsp_status.capabilities)
      require('cmp_nvim_lsp').default_capabilities(capabilities)

      function removekey(table, key)
        local element = table[key]
        table[key] = nil
        return element
      end

      local server_mappings_default = {
        format = true
      }

      for server, server_settings in pairs(servers) do
        if type(server) == 'number' then
          server = server_settings
          server_settings = nil
        end

        local server_mappings = vim.tbl_extend(
          'force',
          server_mappings_default,
          server_settings and removekey(server_settings, 'mappings') or {}
        )

        lspconfig[server].setup({
          on_attach = function(client, bufnr)
            lsp_status.on_attach(client)
            setup_lsp_mappings(client, bufnr, server_mappings)
          end,
          capabilities = capabilities,
          flags = {
            debounce_text_changes = 140,
          },
          settings = server_settings
        })
      end
    end
  },
  {
    'folke/lsp-colors.nvim',

    config = function()
      require("lsp-colors").setup({
        Error = "#db4b4b",
        Warning = "#e0af68",
        Information = "#0db9d7",
        Hint = "#10B981"
      })
    end
  },
}
