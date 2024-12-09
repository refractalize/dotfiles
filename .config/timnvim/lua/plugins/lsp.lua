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
      "williamboman/mason-lspconfig.nvim",
      "Issafalcon/lsp-overloads.nvim",
    },

    config = function()
      local lspconfig = require("lspconfig")
      local lsp_status = require("lsp-status")

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
      local severity = { min = vim.diagnostic.severity.WARN }
      local float_options = {
        source = true,
      }

      vim.keymap.set("n", "<space>e", function()
        vim.diagnostic.open_float(float_options)
      end, opts)
      vim.keymap.set("n", "[d", function()
        vim.diagnostic.goto_prev({ severity = severity, float = float_options })
      end, opts)
      vim.keymap.set("n", "]d", function()
        vim.diagnostic.goto_next({ severity = severity, float = float_options })
      end, opts)
      vim.keymap.set("n", "<space>q", function()
        vim.diagnostic.setloclist()
      end, opts)

      lsp_status.register_progress()

      local format_lsp_overrides = {
        python = "ruff",
      }

      local on_attach = function(client, bufnr, options)
        options = vim.tbl_extend("force", {
          format = true,
        }, options or {})

        lsp_status.on_attach(client)

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
          local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
          local name = format_lsp_overrides[filetype] or client.name
          vim.keymap.set("n", "<M-f>", function()
            vim.lsp.buf.format({ async = true, name = name })
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
        ts_ls = {
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
        pylsp = {
          mappings = {
            format = false,
          },
          settings = {
            pylsp = {
              plugins = {
                autopep8 = {
                  enabled = false,
                },
                jedi_completion = {
                  enabled = false,
                },
                jedi_definition = {
                  enabled = false,
                },
                jedi_hover = {
                  enabled = false,
                },
                jedi_references = {
                  enabled = false,
                },
                jedi_signature_help = {
                  enabled = false,
                },
                jedi_symbols = {
                  enabled = false,
                },
                mccabe = {
                  enabled = false,
                },
                preload = {
                  enabled = false,
                },
                pycodestyle = {
                  enabled = false,
                },
                pyflakes = {
                  enabled = false,
                },
                rope_autoimport = {
                  copmletions = {
                    enabled = false,
                  },
                  code_actions = {
                    enabled = false,
                  },
                },
                yapf = {
                  enabled = false,
                },
                pylsp_mypy = {
                  -- dmypy = true,
                  --   overrides = { "--python-executable", ".direnv/python-3.10/bin/python", true },
                },
              },
            },
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
        basedpyright = {
          -- on_new_config = function(new_config, new_root_dir)
          --   local pythonPath = vim.fn.glob(new_root_dir .. "/.direnv/*/bin/python")
          --   if new_config.settings.python == nil then
          --     new_config.settings.python = {}
          --   end
          --   new_config.settings.python.pythonPath = pythonPath
          --   return new_config
          -- end,
          settings = {
            basedpyright = {
              -- Using Ruff's import organizer
              disableOrganizeImports = true,
              analysis = {
                diagnosticMode = "workspace",
              },
            },
          },
          mappings = {
            format = false,
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
          -- "pylsp",
          "rust_analyzer",
          "bashls",
          "ts_ls",
          "eslint",
          "yamlls",
          "omnisharp",
          -- "basedpyright",
        },

        handlers = {
          setup_language_server,
        },
      })

      vim.diagnostic.config({
        virtual_text = { severity = severity },
        signs = { severity = severity },
        underline = { severity = severity },
        float = { severity = severity },
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
