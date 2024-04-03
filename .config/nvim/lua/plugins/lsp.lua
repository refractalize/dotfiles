return {
  {
    "williamboman/mason-lspconfig.nvim",

    dependencies = {
      "williamboman/mason.nvim",
    },
  },
  {
    "neovim/nvim-lspconfig",

    dependencies = {
      "lsp-status.nvim",
      "nvim-cmp",
      "vim-matchup",
      "SmiteshP/nvim-navic",
      "williamboman/mason-lspconfig.nvim",
    },

    config = function()
      local lspconfig = require("lspconfig")
      local lsp_status = require("lsp-status")
      local navic = require("nvim-navic")

      vim.cmd([[
        sign define DiagnosticSignError text=🤬
        sign define DiagnosticSignWarn text=🤔
        sign define DiagnosticSignInfo text=🤓
        sign define DiagnosticSignHint text=🤓
      ]])

      local opts = {
        noremap = true,
        silent = true,
      }
      vim.api.nvim_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
      vim.api.nvim_set_keymap(
        "n",
        "[d",
        "<cmd>lua vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.INFO } })<CR>",
        opts
      )
      vim.api.nvim_set_keymap(
        "n",
        "]d",
        "<cmd>lua vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.INFO } })<CR>",
        opts
      )
      vim.api.nvim_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

      lsp_status.register_progress()

      local on_attach = function(client, bufnr, options)
        options = vim.tbl_extend("force", {
          format = true,
        }, options or {})

        lsp_status.on_attach(client)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end

        vim.keymap.set("n", "gD", function()
          vim.lsp.buf.declaration()
        end, { buffer = bufnr })
        vim.keymap.set("n", "gd", function()
          vim.lsp.buf.definition()
        end, { buffer = bufnr })
        vim.keymap.set("n", "K", function()
          vim.lsp.buf.hover()
        end, { buffer = bufnr })
        vim.keymap.set("n", "gi", function()
          vim.lsp.buf.implementation()
        end, { buffer = bufnr })
        vim.keymap.set("n", "gk", function()
          vim.lsp.buf.signature_help()
        end, { buffer = bufnr })
        vim.keymap.set("i", "<C-k>", function()
          vim.lsp.buf.signature_help()
        end, { buffer = bufnr })
        vim.keymap.set("n", "gt", function()
          vim.lsp.buf.type_definition()
        end, { buffer = bufnr })
        vim.keymap.set("n", "<Leader>rn", function()
          vim.lsp.buf.rename()
        end, { buffer = bufnr })

        if client.server_capabilities.documentFormattingProvider and options.format or options.format == "force" then
          vim.keymap.set("n", "<M-f>", function()
            vim.lsp.buf.format({ async = true })
          end, { buffer = bufnr })
        end

        if options.setup then
          options.setup(client, bufnr)
        end
      end

      local capabilities = vim.tbl_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        lsp_status.capabilities,
        require("cmp_nvim_lsp").default_capabilities()
      )

      local server_overrides = {
        tsserver = {
          mappings = {
            format = false,
          },
        },
        bashls = {
          filetypes = { "sh", "zsh" },
        },
        eslint = {
          mappings = {
            format = false,
            setup = function(client, bufnr)
              vim.keymap.set("n", "<M-F>", "<Cmd>EslintFixAll<CR>", { buffer = bufnr })
            end,
          },
        },
        lua_ls = {
          mappings = {
            format = false,
          },
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                globals = {
                  "vim",
                  "require",
                },
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.env.VIMRUNTIME,
                },
              },
            },
          },
        },
        omnisharp = {
          cmd = { "dotnet", "/Users/tim/.local/share/nvim/mason/packages/omnisharp/libexec/OmniSharp.dll" },
          enable_editorconfig_support = true,
          enable_roslyn_analyzers = true,
          analyze_open_documents_only = true,
          mappings = {
            format = "force",
          },
        },
      }

      local function setup_language_server(server_name)
        local server_options = server_overrides[server_name] or {}

        local setup_options = vim.tbl_extend("force", {
          on_attach = function(client, bufnr)
            on_attach(client, bufnr, server_options.mappings)
          end,
          capabilities = capabilities,
          flags = {
            debounce_text_changes = 140,
          },
        }, server_options)

        lspconfig[server_name].setup(setup_options)
      end

      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        ensure_installed = {
          "cssls",
          "html",
          "jsonls",
          "julials",
          "pylsp",
          "rust_analyzer",
          "bashls",
          "tsserver",
          "eslint",
        },

        handlers = {
          setup_language_server,
        },
      })

      vim.diagnostic.config({
        virtual_text = { severity = { min = vim.diagnostic.severity.INFO } },
        signs = { severity = { min = vim.diagnostic.severity.INFO } },
        underline = { severity = { min = vim.diagnostic.severity.INFO } },
        float = { severity = { min = vim.diagnostic.severity.INFO } },
      })
    end,
  },
  {
    "folke/lsp-colors.nvim",

    config = function()
      require("lsp-colors").setup({
        Error = "#db4b4b",
        Warning = "#e0af68",
        Information = "#0db9d7",
        Hint = "#10B981",
      })
    end,
  },
}
