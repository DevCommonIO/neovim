return {
	{
		"HiPhish/nvim-ts-rainbow2",
		event = "VeryLazy",
		config = function()
			require("nvim-treesitter.configs").setup({
				rainbow = {
					enable = true,
					-- list of languages you want to enable rainbow for
					query = {
						[""] = "rainbow-parens", -- default
						tsx = "rainbow-parens",
						javascript = "rainbow-parens",
						typescript = "rainbow-parens",
						html = "rainbow-parens",
						lua = "rainbow-blocks",
					},
					strategy = {
						[""] = require("ts-rainbow.strategy.global"),
						tsx = require("ts-rainbow.strategy.local"),
					},
					-- highlight groups are handled by your colorscheme
				},
			})
		end,
	},
}
