return {
	-- tools
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			opts = opts or {}
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"selene",
				"luacheck",
				"shellcheck",
				"shfmt",
				"tailwindcss-language-server",
				"typescript-language-server",
				"css-lsp",
			})
			return opts
		end,
	},

	-- lsp servers
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			
			-- Configure servers directly
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true) },
						telemetry = { enable = false },
					},
				},
			})
			
			-- Use ts_ls instead of deprecated tsserver
			lspconfig.ts_ls.setup({})
			lspconfig.cssls.setup({})
			lspconfig.html.setup({})
			lspconfig.tailwindcss.setup({})
			lspconfig.yamlls.setup({})
		end,
	},
}
