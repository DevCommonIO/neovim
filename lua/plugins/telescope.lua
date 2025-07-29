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
		local action_state = require("telescope.actions.state")
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values

		local function copilot_chat_prompt()
			pickers
				.new({}, {
					prompt_title = "Copilot Chat Prompt",
					finder = finders.new_table({
						results = {
							"Explain this code",
							"Suggest tests for this code",
							"Review this code for improvements",
							"Fix bugs in this code",
							"Generate documentation",
							"Translate to TypeScript",
						},
					}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr, map)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selection = action_state.get_selected_entry()
							vim.cmd("CopilotChat " .. selection[1])
						end)
						return true
					end,
				})
				:find()
		end

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
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
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
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("todo-comments")

		local keymap = vim.keymap

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in project" })
		keymap.set("v", "<leader>fs", function()
			vim.cmd('normal! "vy')
			local text = vim.fn.getreg("v")
			text = string.gsub(text, "\n", "")
			require("telescope.builtin").live_grep({
				default_text = text,
				case_mode = "ignore_case",
			})
		end, { desc = "Live grep visual selection" })

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
				case_mode = "ignore_case",
			})
		end, { desc = "Fuzzy search word under cursor in buffer" })
		keymap.set("v", "<leader>fw", function()
			vim.cmd('normal! "vy')
			local text = vim.fn.getreg("v")
			text = string.gsub(text, "\n", "")
			require("telescope.builtin").current_buffer_fuzzy_find({
				default_text = text,
				case_mode = "ignore_case",
			})
		end, { desc = "Fuzzy search visual selection in buffer" })

		keymap.set("n", "<leader>cC", copilot_chat_prompt, { desc = "Copilot Chat Prompt Picker" })
	end,
}
