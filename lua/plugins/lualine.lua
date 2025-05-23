return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
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
	},
}
