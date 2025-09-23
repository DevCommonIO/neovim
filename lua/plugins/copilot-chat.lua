-- lua/plugins/copilot-chat.lua
return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		"zbirenbaum/copilot.lua",
		"nvim-lua/plenary.nvim",
	},
	event = "VeryLazy",

	keys = {
		-- Ask (current buffer or buffers if extras were added)
		{
			"<leader>cc",
			function()
				local q = vim.fn.input("Copilot (buffer/buffers): ")
				if q ~= "" then
					require("CopilotChat").ask(q)
				end
			end,
			desc = "CopilotChat: Ask (buffer/buffers)",
			mode = "n",
		},

		-- Ask across all listed buffers
		{
			"<leader>cC",
			function()
				local q = vim.fn.input("Copilot (#buffers): ")
				if q ~= "" then
					require("CopilotChat").ask("> #buffers\n" .. q)
				end
			end,
			desc = "CopilotChat: Ask (all listed buffers)",
			mode = "n",
		},

		-- Add current file to Copilot context (promote to listed buffer)
		{
			"<leader>cf",
			function()
				local path = vim.api.nvim_buf_get_name(0)
				if path == "" then
					vim.notify("No file for this buffer", vim.log.levels.WARN)
					return
				end
				local bufnr = vim.fn.bufadd(path)
				vim.fn.bufload(bufnr)
				vim.api.nvim_buf_set_option(bufnr, "buflisted", true)

				local chat = require("CopilotChat")
				chat.config.extra_files = chat.config.extra_files or {}
				if not vim.tbl_contains(chat.config.extra_files, path) then
					table.insert(chat.config.extra_files, path)
					vim.notify("Added to Copilot buffers: " .. vim.fn.fnamemodify(path, ":t"))
				else
					vim.notify("Already in Copilot buffers: " .. vim.fn.fnamemodify(path, ":t"))
				end
			end,
			desc = "CopilotChat: Add current file to buffers context",
			mode = "n",
		},
		{
			"<leader>cd",
			function()
				require("CopilotChat").reset()
			end,
			desc = "CopilotChat: Reset",
		},

		-- Ask about visual selection
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

		-- Toggle model (GPT-5 ↔ Claude Sonnet 4)
		{
			"<leader>cA",
			function()
				local chat = require("CopilotChat")
				local cur = chat.config.model or "gpt-4.1"
				local nextm = (cur == "gpt-4.1") and "gpt-5" or "gpt-4.1"
				chat.config.model = nextm
				vim.notify("CopilotChat model: " .. nextm, vim.log.levels.INFO)
			end,
			desc = "CopilotChat: Toggle model (GPT 5 ↔ GPT 4)",
			mode = "n",
		},
	},

	opts = {
		show_help = false,
		context = "buffer",
		model = "gpt-4.1",
		sticky_context = true,
		extra_files = {}, -- absolute paths promoted to buffers
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
		local chat = require("CopilotChat")
		chat.setup(opts)

		-- Inject context header automatically:
		-- if extra_files exist → "#buffers", else "#buffer".
		-- Skips if user already included #buffer/#buffers.
		local raw_ask = chat.ask
		chat.ask = function(user_prompt, call_opts)
			user_prompt = user_prompt or ""
			if user_prompt:find("#buffer", 1, true) or user_prompt:find("#buffers", 1, true) then
				return raw_ask(user_prompt, call_opts)
			end
			local extras = chat.config.extra_files or {}
			local header = (#extras > 0) and "> #buffers\n" or "> #buffer\n"
			return raw_ask(header .. user_prompt, call_opts)
		end
	end,
}
