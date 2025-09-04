-- colorscheme.lua
return {
	"loctvl842/monokai-pro.nvim",
	priority = 1000,
	config = function()
		require("monokai-pro").setup({
			transparent_background = false,
			terminal_colors = true,
			devicons = true,
			filter = "pro", -- "pro" | "classic" | "machine" | "ristretto" | "spectrum" | "octagon"
			styles = {
				comments = { italic = true },
				keywords = { italic = false },
				functions = { bold = true },
				variables = {},
			},
			-- plugins = {
			-- 	bufferline = false, -- ⬅ turn off
			-- 	indent_blankline = true,
			-- 	nvim_tree = true,
			-- 	telescope = true,
			-- 	treesitter = true,
			-- 	gitsigns = false,
			-- 	lsp = true,
			-- },
		})
		vim.cmd.colorscheme("monokai-pro")
	end,
}
