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
		-- Normal mode: ask about buffer context
		{
			"<leader>cc",
			function()
				vim.ui.input({ prompt = "Ask Copilot about current buffer: " }, function(input)
					if input and input ~= "" then
						require("CopilotChat").ask(input, {
							selection = require("CopilotChat.select").buffer,
						})
					end
				end)
			end,
			desc = "Ask Copilot (Buffer Context)",
		},

		{ "<leader>ce", "<cmd>CopilotChatExplain<cr>", desc = "Explain code" },
		{ "<leader>cr", "<cmd>CopilotChatReview<cr>", desc = "Review code" },
		{ "<leader>ct", "<cmd>CopilotChatTests<cr>", desc = "Suggest tests" },
		{ "<leader>cf", "<cmd>CopilotChatFix<cr>", desc = "Suggest fix" },
		{
			"<leader>cd",
			function()
				require("CopilotChat").clear()
			end,
			desc = "Clear Copilot Chat context",
		},

		-- Visual mode: ask about selection
		{
			mode = "v",
			"<leader>cq",
			function()
				vim.ui.input({ prompt = "Ask Copilot about selected code: " }, function(input)
					if input and input ~= "" then
						require("CopilotChat").ask(input, {
							selection = require("CopilotChat.select").visual,
						})
					end
				end)
			end,
			desc = "Ask Copilot (Visual Selection)",
		},
		{
			mode = "v",
			"<leader>cc",
			function()
				require("CopilotChat").ask("Explain this code", {
					selection = require("CopilotChat.select").visual,
				})
			end,
			desc = "Explain with Copilot (Visual)",
		},
	},
	opts = {
		show_help = false,
		context = "buffer",
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
