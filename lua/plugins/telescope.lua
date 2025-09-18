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
		local function get_visual_selection_text()
			local save_reg = vim.fn.getreg('"')
			local save_type = vim.fn.getregtype('"')
			vim.cmd('noau normal! "vy')
			local text = vim.fn.getreg('"')
			vim.fn.setreg('"', save_reg, save_type)
			text = text:gsub("\n", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
			return text
		end
		-- local function get_visual_selection()
		-- 	local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
		-- 	local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
		-- 	if csrow == cerow then
		-- 		return string.sub(vim.fn.getline(csrow), cscol, cecol)
		-- 	end
		-- 	local lines = vim.fn.getline(csrow, cerow)
		-- 	lines[1] = string.sub(lines[1], cscol)
		-- 	lines[#lines] = string.sub(lines[#lines], 1, cecol)
		-- 	return table.concat(lines, "\n")
		-- end

		local map = vim.keymap.set
		local opts = { noremap = true, silent = true }
		local base_opts = { noremap = true, silent = true }

		local function with_desc(desc)
			return vim.tbl_extend("force", base_opts, { desc = desc })
		end

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

		-- Buffer fuzzy search by word/selection
		map("n", "<leader>fw", function()
			local word = vim.fn.expand("<cword>")
			builtin.current_buffer_fuzzy_find({ default_text = word, case_mode = "ignore_case" })
		end, { desc = "Fuzzy find word in buffer", unpack(opts) })

		map("x", "<leader>fs", function()
			local text = get_visual_selection_text()
			if text ~= "" then
				-- literal string search; respects ripgrep smart-case
				-- builtin.grep_string({ search = text })
				builtin.live_grep({ default_text = text, case_mode = "ignore_case" })
			else
				builtin.live_grep()
			end
		end, with_desc("Grep visual selection"))

		-- Fuzzy find selection in current buffer
		map("x", "<leader>fw", function()
			local text = get_visual_selection_text()
			if text ~= "" then
				builtin.current_buffer_fuzzy_find({ default_text = text })
			else
				builtin.current_buffer_fuzzy_find()
			end
		end, with_desc("Fuzzy find selection in buffer"))

		-- Telescope setup
		require("telescope").setup({
			defaults = {
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						width = 0.96, -- use 90% of the screen width
						height = 0.94, -- use 80% of the screen height
					},
					prompt_position = "top", -- <== put input at the top
					preview_width = 0.55, -- optional: tweak preview size
				},
				sorting_strategy = "ascending", -- makes results grow down from prompt
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
				mappings = {
					i = {
						["<C-k>"] = "move_selection_previous",
						["<C-j>"] = "move_selection_next",
					},
				},
			},
			pickers = {
				find_files = {
					hidden = true,
					layout_config = { horizontal = { preview_width = 0.48 } }, -- per-picker tweak
				},
				live_grep = {
					layout_config = { horizontal = { preview_width = 0.46 } },
				},
			},
		})

		-- load native fzf if compiled
		pcall(require("telescope").load_extension, "fzf")
	end,
}
