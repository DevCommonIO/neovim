-- lua/plugins/telescope-git.lua
return {
	{
		"isak102/telescope-git-file-history.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
			"tpope/vim-fugitive", -- required to open historical file versions
			"sindrets/diffview.nvim", -- for pretty side-by-side diffs
		},
		config = function()
			local ok_t, telescope = pcall(require, "telescope")
			if not ok_t then
				return
			end

			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			-- helper: open Diffview for the selected commit against current file
			local function open_diff_for_entry(prompt_bufnr)
				local entry = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if not entry or not entry.value then
					return
				end
				-- entry.value is the commit SHA; diff only that commit’s change for current file
				vim.cmd("DiffviewOpen " .. entry.value .. "^! -- %")
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

			-- Current file history → pick a commit → <CR> opens Diffview
			map("n", "<leader>gh", function()
				require("telescope").extensions.git_file_history.git_file_history()
			end, { desc = "Git: file history (current buffer)" })

			-- (Optional) Open Diffview’s native history UI for current file
			map("n", "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", { desc = "Git: file history (Diffview)" })

			-- (Optional) Other handy git pickers
			map("n", "<leader>gC", builtin.git_commits, { desc = "Git: commits (repo)" })
			map("n", "<leader>gB", builtin.git_bcommits, { desc = "Git: commits (buffer)" })
			map("n", "<leader>gs", builtin.git_status, { desc = "Git: status" })
		end,
	},
}
