return {
  {
    "neovim/nvim-lspconfig",

    opts = function(_, opts)
      local keys = require("lazyvim.plugins.lsp.keymaps").get()

      return vim.tbl_deep_extend("force", opts, {
        diagnostics = {
          underline = { severity = { min = vim.diagnostic.severity.WARN } },
          virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
          float = { source = true },
        },
        servers = {
          omnisharp = {
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
                EnableAnalyzersSupport = true,
                --
                -- Enables support for showing unimported types and unimported extension
                -- methods in completion lists. When committed, the appropriate using
                -- directive will be added at the top of the current file. This option can
                -- have a negative impact on initial completion responsiveness,
                -- particularly for the first few completion sessions after opening a
                -- solution.
                EnableImportCompletion = true,
                -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
                -- true
                AnalyzeOpenDocumentsOnly = true,
              },
              Sdk = {
                -- Specifies whether to include preview versions of the .NET SDK when
                -- determining which version to use for project loading.
                IncludePrereleases = true,
              },
            },
          },
          pylsp = {
            settings = {
              pylsp = {
                plugins = {
                  autopep8 = {
                    enabled = false,
                  },
                  jedi_completion = {
                    enabled = true,
                  },
                  jedi_definition = {
                    enabled = true,
                  },
                  jedi_hover = {
                    enabled = true,
                  },
                  jedi_references = {
                    enabled = true,
                  },
                  jedi_signature_help = {
                    enabled = true,
                  },
                  jedi_symbols = {
                    enabled = true,
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
                },
              },
            },
          },
          -- pyright = {
          --   ---  @param params lsp.InitializeParams
          --   ---  @param config vim.lsp.ClientConfig
          --   before_init = function(params, config)
          --     local venvPath = params.rootPath .. "/.venv"
          --     vim.notify("Checking virtual environment in " .. venvPath, vim.log.levels.INFO)
          --
          --     local stat = vim.uv.fs_stat(venvPath)
          --     local exists = stat and stat.type == 'directory'
          --
          --     if exists then
          --       vim.notify("Using virtual environment in " .. venvPath, vim.log.levels.INFO)
          --       config.settings.python.pythonPath = venvPath .. "/bin/python"
          --     end
          --   end,
          -- },
        },
        setup = {
          pylsp = function()
            --- @param client vim.lsp.Client
            LazyVim.lsp.on_attach(function(client, _)
              client.server_capabilities.signatureHelpProvider = nil
              client.server_capabilities.hoverProvider = false
              client.server_capabilities.renameProvider = false
            end, "pylsp")
          end,
          vtsls = function()
            --- @param client vim.lsp.Client
            LazyVim.lsp.on_attach(function(client, _)
              client.server_capabilities.inlayHintProvider = false
              client.server_capabilities.documentFormattingProvider = false
            end, "vtsls")
          end,
        },
      })
    end,
  },
}
