-- lua/plugins/dap.lua
return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- REQUIRED for dap-ui (fixes your error)
			"nvim-neotest/nvim-nio",

			-- DAP UI
			{ "rcarriga/nvim-dap-ui" },

			-- Mason bridge for adapters
			{ "jay-babu/mason-nvim-dap.nvim" },

			-- Python adapter helper
			{ "mfussenegger/nvim-dap-python" },

			-- Optional: Telescope integration
			{ "nvim-telescope/telescope-dap.nvim" },
		},
		config = function()
			local dap = require("dap")

			-- Install adapters
			require("mason-nvim-dap").setup({
				ensure_installed = { "python" }, -- add "node2" if you want Node later
				automatic_installation = true,
			})

			-- Python (debugpy)
			local ok_py, dap_python = pcall(require, "dap-python")
			if ok_py then
				dap_python.setup("python")
			end

			-- Keymaps
			local map, opts = vim.keymap.set, { noremap = true, silent = true }
			map("n", "<F5>", function()
				dap.continue()
			end, opts)
			map("n", "<F10>", function()
				dap.step_over()
			end, opts)
			map("n", "<F11>", function()
				dap.step_into()
			end, opts)
			map("n", "<F12>", function()
				dap.step_out()
			end, opts)
			map("n", "<leader>db", function()
				dap.toggle_breakpoint()
			end, opts)
			map("n", "<leader>dr", function()
				dap.repl.open()
			end, opts)

			-- dap-ui (guarded)
			local ok_ui, dapui = pcall(require, "dapui")
			if ok_ui then
				dapui.setup()
				dap.listeners.after.event_initialized["dapui_config"] = function()
					dapui.open()
				end
				dap.listeners.before.event_terminated["dapui_config"] = function()
					dapui.close()
				end
				dap.listeners.before.event_exited["dapui_config"] = function()
					dapui.close()
				end
			end

			-- Telescope DAP
			pcall(require("telescope").load_extension, "dap")
		end,
	},
}
