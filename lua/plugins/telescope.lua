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
		local ok_telescope, telescope = pcall(require, "telescope")
		if not ok_telescope then
			return
		end

		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		-- Helper: capture visual selection without touching registers
		local function get_visual_selection()
			local _, ls, cs = unpack(vim.fn.getpos("v"))
			local _, le, ce = unpack(vim.fn.getpos("."))
			if ls > le or (ls == le and cs > ce) then
				ls, le, cs, ce = le, ls, ce, cs
			end
			local lines = vim.fn.getline(ls, le)
			if #lines == 0 then
				return ""
			end
			lines[#lines] = string.sub(lines[#lines], 1, ce)
			lines[1] = string.sub(lines[1], cs)
			return table.concat(lines, "\n")
		end

		-- Optional: tiny picker for Copilot Chat prompts
		local function copilot_chat_prompt()
			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local conf = require("telescope.config").values
			local actions_state = require("telescope.actions.state")

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
					attach_mappings = function(prompt_bufnr, _)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selection = actions_state.get_selected_entry()
							vim.cmd("CopilotChat " .. selection[1])
						end)
						return true
					end,
				})
				:find()
		end

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				dynamic_preview_title = true,
				sorting_strategy = "ascending",
				layout_config = {
					prompt_position = "top",
					horizontal = { width = 0.9, preview_width = 0.6 },
					vertical = { preview_height = 0.7 },
					width = 0.9,
					height = 0.85,
				},
				file_ignore_patterns = {
					"node_modules",
					"%.git",
					"dist/",
					"__pycache__/",
				},
				vimgrep_arguments = { -- ripgrep
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
				},
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-u>"] = actions.preview_scrolling_up,
						["<C-d>"] = actions.preview_scrolling_down,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<Esc>"] = actions.close,
					},
					n = {
						["q"] = actions.close,
					},
				},
			},

			pickers = {
				find_files = {
					hidden = true, -- show dotfiles
					follow = true, -- follow symlinks
				},
				live_grep = {
					-- You can set additional args at call-site via opts.additional_args
				},
				buffers = {
					sort_mru = true,
					ignore_current_buffer = true,
					mappings = {
						i = { ["<C-x>"] = actions.delete_buffer },
						n = { ["x"] = actions.delete_buffer },
					},
				},
			},
		})

		-- Extensions (load softly)
		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "todo-comments")

		---------------------------------------------------------------------------
		-- Keymaps (simple, consistent)
		---------------------------------------------------------------------------
		local map = vim.keymap.set
		local opts = { noremap = true, silent = true }

		map("n", "<leader>ff", builtin.find_files, { desc = "Files", unpack(opts) })
		map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files", unpack(opts) })
		map("n", "<leader>fb", builtin.buffers, { desc = "Buffers", unpack(opts) })
		map("n", "<leader>fs", builtin.live_grep, { desc = "Grep project", unpack(opts) })
		map("n", "<leader>fc", builtin.grep_string, { desc = "Grep word (cwd)", unpack(opts) })
		map("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search in buffer", unpack(opts) })
		map("n", "<leader>tr", builtin.resume, { desc = "Resume", unpack(opts) })

		-- LSP helpers (pairs nicely with your lsp.lua)
		map("n", "<leader>fd", builtin.lsp_document_symbols, { desc = "Document symbols", unpack(opts) })
		map("n", "<leader>fu", builtin.lsp_references, { desc = "Symbol references", unpack(opts) })

		-- Todo-comments
		map("n", "<leader>ft", function()
			vim.cmd("TodoTelescope")
		end, { desc = "Todos", unpack(opts) })

		-- Grep: visual selection → live_grep (no register clobber)
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

		-- Copilot Chat prompt picker (optional)
		map("n", "<leader>cC", copilot_chat_prompt, { desc = "Copilot Chat Prompt Picker", unpack(opts) })
	end,
}
