return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "auto",
				globalstatus = true,
				section_separators = { left = "", right = "" },
				component_separators = { left = "|", right = "|" },
				disabled_filetypes = {
					statusline = { "dashboard", "NvimTree", "lazy", "alpha" },
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {
					{
						"filename",
						path = 1,
						symbols = {
							modified = " [+]",
							readonly = " [RO]",
							unnamed = "[No Name]",
						},
					},
				},
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_c = {
					{
						"filename",
						path = 1,
					},
				},
				lualine_x = { "location" },
			},
			extensions = { "nvim-tree", "quickfix", "man", "toggleterm", "fugitive" },
		})

		vim.opt.guicursor = {
			"n:block", -- normal mode: block
			"v:block-CursorVisual", -- visual mode: block with red
			"c:block", -- command-line mode
			"i-ci-ve:blinkon0-block-CursorInsert", -- insert mode: green
			"r-cr:hor20",
			"o:hor50",
		}

		vim.api.nvim_set_hl(0, "CursorVisual", { fg = "black", bg = "#ff0000", bold = true })
		vim.api.nvim_set_hl(0, "CursorInsert", { fg = "black", bg = "#00ff00", bold = true })
	end,
}
