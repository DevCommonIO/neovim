-- lua/plugins/copilot-chat.lua
return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		"zbirenbaum/copilot.lua",
		"nvim-lua/plenary.nvim",
	},
	event = "VeryLazy",
	keys = {
		-- Ask about current buffer
		{
			"<leader>cc",
			function()
				local q = vim.fn.input("Copilot (#buffer): ")
				if q ~= "" then
					require("CopilotChat").ask("#buffer " .. q)
				end
			end,
			desc = "CopilotChat: Ask about current buffer",
			mode = "n",
		},

		-- Ask about all visible buffers
		{
			"<leader>cC",
			function()
				local q = vim.fn.input("Copilot (#buffers:visible): ")
				if q ~= "" then
					require("CopilotChat").ask("#buffers:visible " .. q)
				end
			end,
			desc = "CopilotChat: Ask about visible buffers",
			mode = "n",
		},

		-- Reset conversation (useful when switching topics)
		{
			"<leader>cd",
			function()
				require("CopilotChat").reset()
			end,
			desc = "CopilotChat: Reset",
			mode = "n",
		},

		-- Visual selection → ask
		{
			"<leader>cq",
			function()
				local q = vim.fn.input("Copilot (visual): ")
				if q ~= "" then
					require("CopilotChat").ask(q, { selection = require("CopilotChat.select").visual })
				end
			end,
			desc = "CopilotChat: Ask about selection",
			mode = "v",
		},
	},
	opts = {
		show_help = false,
		context = "buffer", -- default context
		sticky_context = true, -- <== ensures chat continues with the same context
		prompts = {
			Explain = "#buffer Explain how it works.",
			Review = "#buffer Review this code for improvements.",
			Tests = "#buffer Suggest tests for this code.",
			Fix = "#buffer Fix the issue in this code.",
		},
		window = {
			layout = "vertical",
			width = 100,
			title = " Copilot Chat ",
			border = "rounded",
		},
	},
	config = function(_, opts)
		require("CopilotChat").setup(opts)
	end,
}
