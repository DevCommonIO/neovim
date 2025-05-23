return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				dynamic_preview_title = true,
				path_display = { "smart" },
				file_ignore_patterns = {
					"node_modules",
					"%.git",
					"dist/",
					"__pycache__/",
				},
				layout_config = {
					prompt_position = "top",
					horizontal = { width = 0.9, preview_width = 0.6 },
					vertical = { preview_height = 0.7 },
					width = 0.9,
					height = 0.85,
				},
				sorting_strategy = "ascending",
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("todo-comments")

		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
		keymap.set("n", "<leader>fd", builtin.lsp_document_symbols, { desc = "Document symbols" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
		keymap.set(
			"n",
			"<leader>/",
			"<cmd>Telescope current_buffer_fuzzy_find<cr>",
			{ desc = "Search in current buffer" }
		)
		keymap.set("n", "<leader>tr", "<cmd>Telescope resume<cr>", { desc = "Resume last search" })

		keymap.set("n", "<leader>fu", builtin.lsp_references, { desc = "Find references of symbol under cursor" })
		keymap.set("n", "<leader>fw", function()
			local word = vim.fn.expand("<cword>")
			require("telescope.builtin").current_buffer_fuzzy_find({
				default_text = word,
			})
		end, { desc = "Fuzzy search word under cursor in buffer" })
		keymap.set("v", "<leader>fw", function()
			-- Yank selected text into "v" register
			vim.cmd('normal! "vy')
			local text = vim.fn.getreg("v")

			-- Remove line breaks (if multi-line selection)
			text = string.gsub(text, "\n", "")
			require("telescope.builtin").current_buffer_fuzzy_find({
				default_text = text,
			})
		end, { desc = "Fuzzy search visual selection in buffer" })
	end,
}
