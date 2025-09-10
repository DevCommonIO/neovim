-- lua/plugins/matchup-rainbow.lua
return {
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			local rd = require("rainbow-delimiters")

			-- Global settings
			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rd.strategy["global"],
					tsx = rd.strategy["local"], -- better perf on big TSX files
					javascript = rd.strategy["global"],
					typescript = rd.strategy["global"],
					html = rd.strategy["global"],
					lua = rd.strategy["global"],
				},
				query = {
					[""] = "rainbow-delimiters",
					tsx = "rainbow-delimiters-react", -- JSX/TSX-aware queries
					javascript = "rainbow-delimiters",
					typescript = "rainbow-delimiters",
					html = "rainbow-delimiters",
					lua = "rainbow-delimiters",
				},
				-- Optional: custom highlight groups (uncomment to force 6-color cycle)
				-- highlight = {
				--   "RainbowDelimiterRed",
				--   "RainbowDelimiterYellow",
				--   "RainbowDelimiterBlue",
				--   "RainbowDelimiterOrange",
				--   "RainbowDelimiterGreen",
				--   "RainbowDelimiterViolet",
				--   "RainbowDelimiterCyan",
				-- },
			}
		end,
	},
}
