return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local nvimtree = require("nvim-tree")

		-- recommended settings from nvim-tree documentation
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- % → columns helper
		local function tree_width_pct(pct, minw)
			local w = math.floor(vim.o.columns * pct)
			return math.max(w, minw or 35)
		end

		nvimtree.setup({
			view = {
				width = tree_width_pct(0.22, 35), -- ~22% (min 35)
				relativenumber = true,
			},
			renderer = {
				indent_markers = { enable = true },
				icons = {
					glyphs = {
						folder = { arrow_closed = "", arrow_open = "" },
					},
				},
			},
			actions = { open_file = { window_picker = { enable = false } } },
			filters = { custom = { ".DS_Store" } },
			git = { ignore = false },
		})

		-- auto-resize tree on editor width changes
		vim.api.nvim_create_autocmd("VimResized", {
			callback = function()
				local w = tree_width_pct(0.22, 35)
				vim.cmd("NvimTreeResize " .. w)
			end,
		})

		-- keymaps
		local keymap = vim.keymap
		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
		keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle explorer on current file" })
		keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
	end,
}
