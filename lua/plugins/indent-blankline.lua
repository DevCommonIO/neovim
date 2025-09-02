return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("ibl").setup({
			indent = {
				char = "│", -- alternatives: "▏", "▎", "╎"
				tab_char = "│",
			},
			scope = {
				enabled = true, -- set to true if you want lines between functions/blocks
			},
			exclude = {
				filetypes = {
					"help",
					"dashboard",
					"lazy",
					"NvimTree",
					"Trouble",
					"mason",
					"terminal",
				},
				buftypes = { "terminal", "nofile", "quickfix" },
			},
		})
	end,
}

