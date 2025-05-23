return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    -- Mason setup
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "ts_ls", -- TypeScript/JavaScript
        "pyright",
        "jsonls",
        "emmet_ls", -- optional JSX/CSS autocompletion
      },
    })

    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Lua LS
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
        },
      },
    })

    -- TypeScript/JavaScript with TSX/JSX support
    lspconfig.ts_ls.setup({
      capabilities = capabilities,
      filetypes = {
        "javascript", "javascriptreact",
        "typescript", "typescriptreact"
      },
      root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
    })

    -- Python
    lspconfig.pyright.setup({
      capabilities = capabilities,
    })

    -- JSON
    lspconfig.jsonls.setup({
      capabilities = capabilities,
    })

    -- Optional: Emmet for JSX/HTML
    lspconfig.emmet_ls.setup({
      capabilities = capabilities,
      filetypes = {
        "html", "css",
        "javascriptreact", "typescriptreact"
      },
    })
  end,
}
