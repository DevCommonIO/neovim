return {
	"loctvl842/monokai-pro.nvim",
	priority = 1000,
	config = function()
		require("monokai-pro").setup({
			filter = "classic", -- classic | octagon | machine | ristretto | spectrum
		})
		vim.cmd.colorscheme("monokai-pro")

		-- Rainbow delimiter highlight groups adapted to Monokai colors
		vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#f92672" }) -- pink
		vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#e6db74" }) -- yellow
		vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#66d9ef" }) -- blue
		vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#fd971f" }) -- orange
		vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = "#a6e22e" }) -- green
		vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#ae81ff" }) -- purple
		vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#38ccd1" }) -- cyan (extra)
	end,
}
