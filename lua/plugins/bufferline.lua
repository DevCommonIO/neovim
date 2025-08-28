return {
	"romgrk/barbar.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- optional but recommended
	},
	init = function()
		-- Disable built-in tabline
		vim.g.barbar_auto_setup = false
	end,
	config = function()
		require("barbar").setup({
			-- use `animation = false` if you want instant switching
			animation = true,
			auto_hide = false,
			tabpages = false,
			clickable = true,
			icons = {
				buffer_index = false,
				buffer_number = false,
				button = "",
				filetype = {
					enabled = true,
				},
			},
		})

		-- Keymaps for buffer navigation (customize as you wish)
		local map = vim.keymap.set
		map("n", "<Tab>", "<Cmd>BufferNext<CR>", { desc = "Next buffer" })
		map("n", "<S-Tab>", "<Cmd>BufferPrevious<CR>", { desc = "Previous buffer" })
		map("n", "<leader>bc", "<Cmd>BufferClose<CR>", { desc = "Close buffer" })
	end,
}

