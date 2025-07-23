return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		local copilot = require("copilot")

		copilot.setup({
			panel = {
				enabled = true,
				auto_refresh = true,
				keymap = {
					open = "<leader>cp",
					accept = "<C-l>",
					refresh = "<leader>cpr",
					jump_prev = "[[",
					jump_next = "]]",
				},
				layout = {
					position = "right",
					ratio = 0.4,
				},
			},
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<C-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			filetypes = {
				yaml = false,
				markdown = true,
				help = false,
				gitcommit = true,
				gitrebase = true,
				["*"] = true,
			},
		})

		-- Highlight ghost text with a soft gray and italic
		local api = vim.api
		api.nvim_set_hl(0, "CopilotSuggestion", {
			fg = "#555555",
			italic = true,
		})
	end,
}
