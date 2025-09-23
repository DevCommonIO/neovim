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
			animation = true,
			auto_hide = false,
			tabpages = false,
			clickable = true,

			-- 🧠 Buffer sorting logic
			insert_at_end = false,
			insert_at_start = false,

			-- 🎯 Sorting strategy
			sidebar_filetypes = {
				NvimTree = true,
				undotree = true,
				["neo-tree"] = true,
			},

			-- 🎨 Icon config
			icons = {
				buffer_index = false,
				buffer_number = false,
				diagnostics = {
					[vim.diagnostic.severity.ERROR] = { enabled = true, icon = " " },
					[vim.diagnostic.severity.WARN] = { enabled = true, icon = " " },
					[vim.diagnostic.severity.INFO] = { enabled = true, icon = " " },
					[vim.diagnostic.severity.HINT] = { enabled = true, icon = "󰌵 " },
				},
				gitsigns = {
					added = { enabled = true, icon = "+" },
					changed = { enabled = true, icon = "~" },
					deleted = { enabled = true, icon = "-" },
				},
				filetype = { enabled = true },
				separator = { left = "▎", right = "" },
				modified = { enabled = true, icon = "●" },
				pinned = { enabled = true, icon = "", button = "" },
				button = "", -- Close buffer icon
			},
		})

		-- ⌨️ Buffer navigation keymaps
		local map = vim.keymap.set
		local opts = { noremap = true, silent = true }

		local function smart_buffer_close()
			local bufnr = vim.api.nvim_get_current_buf()
			local name = vim.api.nvim_buf_get_name(bufnr)
			local modified = vim.api.nvim_buf_get_option(bufnr, "modified")

			-- Unnamed buffer: just wipe it forcefully (no write)
			if name == "" then
				vim.cmd("silent! bd!")
				return
			end

			-- Named & modified: prompt to save using 'confirm'
			if modified then
				vim.cmd("confirm BufferClose")
			else
				vim.cmd("BufferClose")
			end
		end

		map("n", "<leader>bc", smart_buffer_close, { desc = "Close current buffer" })
		map("n", "<leader>bo", "<Cmd>BufferCloseAllButCurrent<CR>", { desc = "Close all but current buffer" })
		map("n", "<leader>bp", "<Cmd>BufferPin<CR>", { desc = "Pin/unpin buffer" })
		map("n", "<leader>bn", "<Cmd>enew<CR>", { desc = "New empty buffer" })
		map("n", "<Tab>", "<Cmd>BufferNext<CR>", { desc = "Next buffer" })
		map("n", "<S-Tab>", "<Cmd>BufferPrevious<CR>", { desc = "Previous buffer" })
		map("n", "<leader>bh", "<Cmd>BufferMovePrevious<CR>", { desc = "Move buffer left" })
		map("n", "<leader>bl", "<Cmd>BufferMoveNext<CR>", { desc = "Move buffer right" })

		-- map("n", "<Tab>", "<Cmd>BufferNext<CR>", { desc = "Next buffer" })
		-- map("n", "<S-Tab>", "<Cmd>BufferPrevious<CR>", { desc = "Previous buffer" })
		--   map("n", "<leader>bc", smart_buffer_close, { desc = "Close current buffer" })
		-- map("n", "<leader>bo", "<Cmd>BufferCloseAllButCurrent<CR>", { desc = "Close all but current buffer" })
		-- map("n", "<leader>bp", "<Cmd>BufferPin<CR>", { desc = "Pin/unpin buffer" })
		-- map("n", "<leader>bn", "<Cmd>enew<CR>", { desc = "New empty buffer" })
		-- vim.keymap.set("n", "<leader>bh", "<Cmd>BufferMovePrevious<CR>", { desc = "Move buffer left" })
		-- vim.keymap.set("n", "<leader>bl", "<Cmd>BufferMoveNext<CR>", { desc = "Move buffer right" })
	end,
}
