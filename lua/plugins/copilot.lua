return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			panel = {
				enabled = true,
				auto_refresh = true,
				keymap = {
					open = "<leader>cp",
					accept = "<CR>", -- use Enter in panel, keep <C-l> for suggestions
					refresh = "<leader>cpr",
					jump_prev = "[[", -- optional: change to "[c"
					jump_next = "]]", -- optional: change to "]c"
				},
				layout = { position = "right", ratio = 0.4 },
			},
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<C-l>", -- keep this
					accept_word = "<M-l>",
					accept_line = "<M-k>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			filetypes = {
				TelescopePrompt = false,
				NvimTree = false,
				["dap-repl"] = false,
				yaml = false,
				markdown = true,
				gitcommit = true,
				["*"] = true,
			},
		})

		-- Subtle ghost-text style
		vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#555555", italic = true })

		-- Toggle suggestions
		vim.keymap.set("n", "<leader>cs", function()
			vim.g.copilot_suggestion_hidden = not vim.g.copilot_suggestion_hidden
			require("copilot.suggestion")[vim.g.copilot_suggestion_hidden and "dismiss" or "next"]()
			vim.notify("Copilot suggestions: " .. (vim.g.copilot_suggestion_hidden and "OFF" or "ON"))
		end, { desc = "Copilot: toggle suggestions" })

		-- Auto-disable on very large files
		vim.api.nvim_create_autocmd("BufReadPre", {
			callback = function(args)
				local ok, stat = pcall(vim.loop.fs_stat, args.match)
				if ok and stat and stat.size > 1024 * 1024 then
					vim.b.copilot_enabled = false
				end
			end,
		})
	end,
}
