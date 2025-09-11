-- lua/plugins/telescope-git.lua
return {
	{
		"isak102/telescope-git-file-history.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
			"tpope/vim-fugitive", -- open historical snapshots
			"sindrets/diffview.nvim", -- side-by-side diffs + history UI
		},
		config = function()
			local ok_t, telescope = pcall(require, "telescope")
			if not ok_t then
				return
			end

			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local conf = require("telescope.config").values

			-- helper: open Diffview for selected commit against current file
			local function open_diff_for_entry(prompt_bufnr)
				local entry = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if not entry or not entry.value then
					return
				end
				vim.cmd("DiffviewOpen " .. entry.value .. "^! -- %")
			end

			-- custom picker: list git unmerged files (conflicts)
			local function telescope_unmerged_files()
				local files = vim.fn.systemlist({ "git", "diff", "--name-only", "--diff-filter=U" })
				if vim.v.shell_error ~= 0 then
					vim.notify("git diff failed", vim.log.levels.ERROR)
					return
				end
				if #files == 0 then
					vim.notify("No merge conflicts 🎉", vim.log.levels.INFO)
					return
				end

				pickers
					.new({}, {
						prompt_title = "Unmerged files (conflicts)",
						finder = finders.new_table(files),
						sorter = conf.generic_sorter({}),
						attach_mappings = function(bufnr, map)
							local function open_file()
								local entry = action_state.get_selected_entry()
								actions.close(bufnr)
								if entry and entry[1] then
									vim.cmd.edit(entry[1])
								end
							end
							local function open_diffview()
								actions.close(bufnr)
								vim.cmd("DiffviewOpen") -- open merge/diff UI
								vim.cmd("DiffviewFocusFiles") -- show file list to pick from
							end
							map("n", "<CR>", open_file)
							map("i", "<CR>", open_file)
							map("n", "d", open_diffview)
							map("i", "<C-d>", open_diffview)
							return true
						end,
					})
					:find()
			end

			telescope.setup({
				extensions = {
					git_file_history = {
						follow_files = true, -- follow renames/moves
						mappings = {
							i = { ["<CR>"] = open_diff_for_entry },
							n = { ["<CR>"] = open_diff_for_entry, ["d"] = open_diff_for_entry }, -- 'd' also opens diff
						},
					},
				},
			})

			pcall(telescope.load_extension, "git_file_history")

			-- Keymaps
			local map = vim.keymap.set
			local builtin = require("telescope.builtin")

			-- Current file history → pick commit → <CR>/d opens Diffview
			map("n", "<leader>gh", function()
				require("telescope").extensions.git_file_history.git_file_history()
			end, { desc = "Git: file history (current buffer)" })

			-- Diffview’s native file history UI
			map("n", "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", { desc = "Git: file history (Diffview)" })

			-- Conflicts (unmerged files) picker
			map("n", "<leader>gU", telescope_unmerged_files, { desc = "Git: unmerged files (conflicts)" })

			-- Other handy git pickers
			map("n", "<leader>gC", builtin.git_commits, { desc = "Git: commits (repo)" })
			map("n", "<leader>gB", builtin.git_bcommits, { desc = "Git: commits (buffer)" })
			map("n", "<leader>gs", builtin.git_status, { desc = "Git: status" })
		end,
	},
}
