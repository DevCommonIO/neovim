return {
	"jay-babu/mason-nvim-dap.nvim",
	dependencies = {
		"mfussenegger/nvim-dap",
		"mfussenegger/nvim-dap-python",
		"rcarriga/nvim-dap-ui",
		"nvim-telescope/telescope-dap.nvim",
		"theHamsta/nvim-dap-virtual-text",
		"nvim-neotest/nvim-nio", -- ✅ Add this line
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("mason-nvim-dap").setup({
			ensure_installed = { "debugpy", "node-debug2-adapter", "chrome-debug-adapter" },
			automatic_installation = true,
		})

		require("dapui").setup()
		require("nvim-dap-virtual-text").setup({})

		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		-- dap.listeners.before.event_terminated["dapui_config"] = function()
		-- 	dapui.close()
		-- end
		-- dap.listeners.before.event_exited["dapui_config"] = function()
		-- 	dapui.close()
		-- end

		-- === Python ===
		require("dap-python").setup("python")

		-- === Node ===
		dap.adapters.node2 = {
			type = "executable",
			command = "node",
			args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
		}

		-- === Chrome ===
		dap.adapters.chrome = {
			type = "executable",
			command = "node",
			args = { vim.fn.stdpath("data") .. "/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js" },
		}

		-- === Python config ===
		dap.configurations.python = {
			{
				type = "python",
				request = "launch",
				name = "Launch current file",
				program = "${file}",
				console = "integratedTerminal",
				pythonPath = function()
					return os.getenv("VIRTUAL_ENV") and os.getenv("VIRTUAL_ENV") .. "/bin/python" or "python3"
				end,
			},
		}

		-- === JavaScript/TypeScript/React config ===
		local js_config = {
			{
				type = "node2",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				cwd = "${workspaceFolder}",
				sourceMaps = true,
				protocol = "inspector",
				console = "integratedTerminal",
			},
			{
				type = "node2",
				name = "Run current test with npm test (Nightwatch)",
				request = "launch",
				runtimeExecutable = "npm",
				runtimeArgs = { "run", "test", "--" },
				args = { "${file}" },
				cwd = "${workspaceFolder}",
				sourceMaps = true,
				protocol = "inspector",
				console = "integratedTerminal",
			},
			{
				type = "node2",
				request = "attach",
				name = "Attach to process",
				processId = require("dap.utils").pick_process,
				cwd = "${workspaceFolder}",
			},
			{
				type = "chrome",
				request = "attach",
				name = "Attach to Chrome",
				program = "${file}",
				cwd = "${workspaceFolder}",
				port = 9222,
				webRoot = "${workspaceFolder}/src",
				sourceMaps = true,
				protocol = "inspector",
			},
		}

		dap.configurations.javascript = js_config
		dap.configurations.typescript = js_config
		dap.configurations.javascriptreact = js_config
		dap.configurations.typescriptreact = js_config

		-- === Keymaps (same pattern) ===
		local keymap = vim.keymap.set
		keymap("n", "<F5>", dap.continue, { desc = "Continue" })
		keymap("n", "<F10>", dap.step_over, { desc = "Step Over" })
		keymap("n", "<F11>", dap.step_into, { desc = "Step Into" })
		keymap("n", "<F12>", dap.step_out, { desc = "Step Out" })
		keymap("n", "<F4>", function()
			require("telescope").extensions.dap.configurations()
		end, { desc = "Select DAP config" })
		keymap("n", "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
		keymap("n", "<Leader>dr", dap.repl.open, { desc = "Open REPL" })
		keymap("n", "<Leader>de", function()
			require("dap.ui.widgets").hover()
		end, { desc = "Eval under cursor" })
		keymap("n", "<Leader>dw", function()
			require("dapui").elements.watches.add()
		end, { desc = "Add Watch" })
		keymap("n", "<Leader>dv", function()
			require("dap").eval()
		end, { desc = "Evaluate Expression" })
		keymap("n", "<Leader>dl", dap.run_last, { desc = "Run Last" })
		keymap("n", "<Leader>dq", dap.terminate, { desc = "Terminate Debugger" })

		-- Cleanup helper
		vim.api.nvim_create_user_command("DapCloseAll", function()
			dapui.close()
			dap.repl.close()
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.bo[buf].filetype:match("^dapui_") or vim.bo[buf].filetype == "dap-repl" then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end
		end, { desc = "Close all DAP windows" })

		keymap("n", "<Leader>dc", ":DapCloseAll<CR>", { desc = "Close all DAP windows" })

		-- Load Telescope extension
		require("telescope").load_extension("dap")
	end,
}
