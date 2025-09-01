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
				local q = vim.fn.input("Copilot (#buffer): ")
				if q ~= "" then
					require("CopilotChat").ask("#buffer " .. q)
					-- or, if you prefer the selection API:
					-- require("CopilotChat").ask(q, { selection = require("CopilotChat.select").buffer })
				end
			end,
			desc = "CopilotChat: Ask about current buffer",
			mode = "n",
		},
		{
			"<leader>cC",
			function()
				local q = vim.fn.input("Copilot (#buffers:list): ")
				if q ~= "" then
					require("CopilotChat").ask("#buffers:list " .. q)
					-- or, if you prefer the selection API:
					-- require("CopilotChat").ask(q, { selection = require("CopilotChat.select").buffer })
				end
			end,
			desc = "CopilotChat: Ask about opened buffers",
			mode = "n",
		},
		{
			"<leader>cg",
			function()
				local handle = io.popen("git diff")
				local diff = handle:read("*a")
				handle:close()
				if diff ~= "" then
					require("CopilotChat").ask("#diff " .. diff)
				else
					vim.notify("No git diff found.", vim.log.levels.INFO)
				end
			end,
			desc = "CopilotChat: Ask about git diff",
			mode = "n",
		},

		{ "<leader>ce", "<cmd>CopilotChatExplain<cr>", desc = "Explain code" },
		{ "<leader>cr", "<cmd>CopilotChatReview<cr>", desc = "Review code" },
		{ "<leader>ct", "<cmd>CopilotChatTests<cr>", desc = "Suggest tests" },
		{ "<leader>cf", "<cmd>CopilotChatFix<cr>", desc = "Suggest fix" },
		{
			"<leader>cd",
			function()
				require("CopilotChat").reset()
			end,
			desc = "Reset Copilot Chat context",
			mode = "n",
		},

		-- Visual mode: ask about selection
		{
			"<leader>cq",
			function()
				local q = vim.fn.input("Copilot (visual): ")
				if q ~= "" then
					require("CopilotChat").ask(q, {
						selection = require("CopilotChat.select").visual,
					})
				end
			end,
			desc = "CopilotChat: Ask about visual selection",
			mode = "v",
		},
		{
			"<leader>cE",
			function()
				require("CopilotChat").ask("Explain this code", {
					selection = require("CopilotChat.select").visual,
				})
			end,
			desc = "CopilotChat: Explain visual selection",
			mode = "v",
		},
	},
	opts = {
		show_help = false,
		context = "buffer",
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
		model = {
			name = "gpt-5",
			params = {
				temperature = 0.1,
				top_p = 1,
				frequency_penalty = 0,
				presence_penalty = 0,
			},
		},
	},
	config = function(_, opts)
		require("CopilotChat").setup(opts)
	end,
}
