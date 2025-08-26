return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{ "zbirenbaum/copilot.lua" },
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope.nvim" },
	},
	event = "VeryLazy",
	cmd = {
		"CopilotChat",
		"CopilotChatToggle",
		"CopilotChatExplain",
		"CopilotChatReview",
		"CopilotChatTests",
		"CopilotChatFix",
		"CopilotChatVisual",
	},
	keys = {
		-- Normal mode: ask about current buffer
		{
			"<leader>cc",
			function()
				vim.ui.input({ prompt = "Ask Copilot (buffer): " }, function(input)
					if input and input ~= "" then
						require("CopilotChat").ask(input, {
							context = "buffer",
							selection = require("CopilotChat.select").buffer,
						})
					end
				end)
			end,
			desc = "Ask Copilot (Buffer Context)",
		},

		-- Visual mode: free-form question
		{
			mode = "v",
			"<leader>cq",
			function()
				vim.ui.input({ prompt = "Ask Copilot (visual): " }, function(input)
					if input and input ~= "" then
						require("CopilotChat").ask(input, {
							context = "buffer",
							selection = require("CopilotChat.select").visual,
						})
					end
				end)
			end,
			desc = "Ask Copilot (Visual Selection)",
		},

		-- Visual mode: explain selected code
		{
			mode = "v",
			"<leader>ce",
			function()
				require("CopilotChat").ask("Explain this code", {
					context = "buffer",
					selection = require("CopilotChat.select").visual,
				})
			end,
			desc = "Explain Code (Visual)",
		},

		-- Visual mode: suggest tests
		{
			mode = "v",
			"<leader>ct",
			function()
				require("CopilotChat").ask("Suggest tests for this code", {
					context = "buffer",
					selection = require("CopilotChat.select").visual,
				})
			end,
			desc = "Suggest Tests (Visual)",
		},
	},
	opts = {
		show_help = false,
		context = "buffer", -- default, but all calls override it explicitly
		opt = "gpt5",
		prompts = {
			Explain = "Explain how it works.",
			Review = "Review this code for improvements.",
			Tests = "Suggest tests for this code.",
			Fix = "Fix the issue in this code.",
		},
		window = {
			layout = "vertical",
			width = 80,
		},
	},
	config = function(_, opts)
		require("CopilotChat").setup(opts)
	end,
}
