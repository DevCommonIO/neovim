return {
	{
		"tanvirtin/monokai.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("monokai").setup({
				palette = require("monokai").pro,
			})
			-- load the colorscheme here
			vim.cmd([[colorscheme monokai]])
		end,
	},
}
