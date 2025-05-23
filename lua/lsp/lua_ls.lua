-- optional: ~/.config/nvim/lua/lsp/settings/lua_ls.lua
return {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
      },
    },
  }