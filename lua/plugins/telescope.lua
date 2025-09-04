-- lua/plugins/telescope.lua
return {
	"nvim-telescope/telescope.nvim",
	version = "0.1.6", -- optional: pin a stable release
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- icons in results (optional but nice)
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- faster fuzzy
	},
	config = function()
		local builtin = require("telescope.builtin")

		-- helper to get visual selection
		local function get_visual_selection()
			local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
			local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
			if csrow == cerow then
				return string.sub(vim.fn.getline(csrow), cscol, cecol)
			end
			local lines = vim.fn.getline(csrow, cerow)
			lines[1] = string.sub(lines[1], cscol)
			lines[#lines] = string.sub(lines[#lines], 1, cecol)
			return table.concat(lines, "\n")
		end

		local map = vim.keymap.set
		local opts = { noremap = true, silent = true }

		-- Core finders
		map("n", "<leader>ff", builtin.find_files, { desc = "Files", unpack(opts) })
		map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files", unpack(opts) })
		map("n", "<leader>fb", builtin.buffers, { desc = "Buffers", unpack(opts) })
		map("n", "<leader>fs", builtin.live_grep, { desc = "Grep project", unpack(opts) })
		map("n", "<leader>fc", builtin.grep_string, { desc = "Grep word (cwd)", unpack(opts) })
		map("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search in buffer", unpack(opts) })
		map("n", "<leader>tr", builtin.resume, { desc = "Resume", unpack(opts) })

		-- Diagnostics
		map("n", "<leader>q", function()
			builtin.diagnostics({ bufnr = 0 })
		end, { desc = "See current buffer diagnostics" })

		map("n", "<leader>Q", builtin.diagnostics, { desc = "See workspace diagnostics" })
		-- LSP helpers
		map("n", "<leader>fd", builtin.lsp_document_symbols, { desc = "Document symbols", unpack(opts) })
		map("n", "<leader>fu", builtin.lsp_references, { desc = "Symbol references", unpack(opts) })
		-- Grep visual selection
		map("v", "<leader>fs", function()
			local text = get_visual_selection():gsub("\n", " ")
			builtin.live_grep({ default_text = text, case_mode = "ignore_case" })
		end, { desc = "Grep visual selection", unpack(opts) })

		-- Buffer fuzzy search by word/selection
		map("n", "<leader>fw", function()
			local word = vim.fn.expand("<cword>")
			builtin.current_buffer_fuzzy_find({ default_text = word, case_mode = "ignore_case" })
		end, { desc = "Fuzzy find word in buffer", unpack(opts) })

		map("v", "<leader>fw", function()
			local text = get_visual_selection():gsub("\n", " ")
			builtin.current_buffer_fuzzy_find({ default_text = text, case_mode = "ignore_case" })
		end, { desc = "Fuzzy find selection in buffer", unpack(opts) })

		-- Telescope setup
		require("telescope").setup({
			defaults = {
				layout_strategy = "horizontal",
				layout_config = {
					prompt_position = "top", -- <== put input at the top
					preview_width = 0.6, -- optional: tweak preview size
				},
				sorting_strategy = "ascending", -- makes results grow down from prompt
				mappings = {
					i = {
						["<C-k>"] = "move_selection_previous",
						["<C-j>"] = "move_selection_next",
					},
				},
			},
			pickers = {
				find_files = { hidden = true }, -- show dotfiles
			},
		})

		-- load native fzf if compiled
		pcall(require("telescope").load_extension, "fzf")
	end,
}
