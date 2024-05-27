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
      "Issafalcon/lsp-overloads.nvim",
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

        if client.server_capabilities.signatureHelpProvider then
          require("lsp-overloads").setup(client, {})
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
          cmd = { "dotnet", os.getenv("HOME") .. "/.local/share/nvim/mason/packages/omnisharp/libexec/OmniSharp.dll" },

          settings = {
            FormattingOptions = {
              -- Enables support for reading code style, naming convention and analyzer
              -- settings from .editorconfig.
              EnableEditorConfigSupport = true,
              -- Specifies whether 'using' directives should be grouped and sorted during
              -- document formatting.
              OrganizeImports = true,
            },
            MsBuild = {
              -- If true, MSBuild project system will only load projects for files that
              -- were opened in the editor. This setting is useful for big C# codebases
              -- and allows for faster initialization of code navigation features only
              -- for projects that are relevant to code that is being edited. With this
              -- setting enabled OmniSharp may load fewer projects and may thus display
              -- incomplete reference lists for symbols.
              LoadProjectsOnDemand = nil,
            },
            RoslynExtensionsOptions = {
              -- Enables support for roslyn analyzers, code fixes and rulesets.
              enableAnalyzersSupport = true,
              --
              -- Enables support for showing unimported types and unimported extension
              -- methods in completion lists. When committed, the appropriate using
              -- directive will be added at the top of the current file. This option can
              -- have a negative impact on initial completion responsiveness,
              -- particularly for the first few completion sessions after opening a
              -- solution.
              enableImportCompletion = nil,
              -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
              -- true
              -- AnalyzeOpenDocumentsOnly = nil,
            },
            Sdk = {
              -- Specifies whether to include preview versions of the .NET SDK when
              -- determining which version to use for project loading.
              IncludePrereleases = true,
            },
          },
          mappings = {
            format = "force",
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://raw.githubusercontent.com/docker/compose/v1/compose/config/compose_spec.json"] = {
                  "/docker-compose.y*ml",
                  "/docker-compose-*.y*ml",
                },
              },
            },
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
          "yamlls",
          "omnisharp",
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
