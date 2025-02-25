return {
	{
		"rafamadriz/friendly-snippets",
		dependencies = { "L3MON4D3/LuaSnip" }, -- Ensure LuaSnip is installed
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		build = "make install_jsregexp",
		config = function()
			local luasnip = require("luasnip")
			luasnip.config.set_config({
				history = true, -- keep last snippet
				updateevents = "TextChanged,TextChangedI",
			})

			-- Load custom snippets (optional)
			require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
		end,
	},
}
