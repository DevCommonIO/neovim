return {
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = {
			"mfussenegger/nvim-dap",
			"mfussenegger/nvim-dap-python",
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"nvim-telescope/telescope.nvim", -- Add telescope.nvim
			"nvim-telescope/telescope-dap.nvim", -- Add telescope-dap.nvim
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup()
			require("mason-nvim-dap").setup({
				ensure_installed = { "debugpy", "node-debug2-adapter" },
				automatic_installation = true,
				handlers = {},
			})

			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			-- Automatically open and close the dapui on debug sessions
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.open()
			end
			--[[ 			dap.listeners.before.event_stopped["dapui_config"] = function()
				dap.repl.open() -- Ensure the REPL stays open if execution stops due to an error
			end
 ]]
			-- Configure nvim-dap-python
			require("dap-python").setup("python") -- This assumes 'python' is in your PATH. Adjust the path if necessary.

			-- Configure Node.js adapter
			dap.adapters.node2 = {
				type = "executable",
				command = "node",
				args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
			}

			dap.adapters.python = {
				type = "executable",
				command = "python3",
				args = { "-m", "debugpy.adapter" },
			}

			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch Flask App",
					program = "${workspaceFolder}/application.py", -- Change to your main Flask file (e.g., `main.py` if different)
					env = {
						FLASK_APP = "application.py", -- Set this to your main Flask entry point
						FLASK_ENV = "development",
						FLASK_DEBUG = "1",
					},
					console = "integratedTerminal",
					args = { "run", "--no-debugger", "--no-reload" },
					pythonPath = function()
						-- Automatically use the virtualenv if available
						local venv_path = os.getenv("VIRTUAL_ENV")
						if venv_path then
							return venv_path .. "/bin/python"
						end
						return "python3" -- Fallback
					end,
				},
			}

			dap.configurations.javascript = {
				{
					type = "node2",
					request = "launch",
					name = "Launch Node.js Program",
					program = "${file}",
					cwd = vim.fn.getcwd(),
					sourceMaps = true,
					protocol = "inspector",
					console = "integratedTerminal",
				},
				{
					type = "node2",
					request = "attach",
					name = "Attach to Node.js",
					processId = require("dap.utils").pick_process,
					cwd = vim.fn.getcwd(),
					sourceMaps = true,
					console = "integratedTerminal",
					protocol = "inspector",
				},
			}

			dap.configurations.typescript = dap.configurations.javascript
			dap.configurations.javascriptreact = dap.configurations.javascript
			dap.configurations.typescriptreact = dap.configurations.javascript

			-- Keybindings
			vim.keymap.set("n", "<F4>", function()
				require("telescope").extensions.dap.configurations()
			end, { desc = "Select and start debug configuration" })
			vim.keymap.set("n", "<F10>", dap.step_over)
			vim.keymap.set("n", "<F11>", dap.step_into)
			vim.keymap.set("n", "<F12>", dap.step_out)
			vim.keymap.set("n", "<F5>", dap.continue)
			vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
			vim.keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "Open DAP REPL" })
			vim.keymap.set("n", "<Leader>de", function()
				require("dap.ui.widgets").hover()
			end, { desc = "Evaluate expression under cursor" })
			vim.keymap.set("n", "<Leader>dw", function()
				require("dapui").elements.watches.add()
			end, { desc = "Add expression to watch" })
			vim.keymap.set("n", "<Leader>dv", function()
				require("dap").eval()
			end, { desc = "Evaluate expression manually" })
			vim.keymap.set("n", "<Leader>dl", dap.run_last)
			vim.keymap.set("n", "<Leader>dq", dap.terminate, { desc = "Close all dap" })
			vim.keymap.set("n", "<F8>", dap.terminate, { desc = "Terminate Debug Session (F8)" })

			vim.api.nvim_create_user_command("DapCloseAll", function()
				dapui.close()
				dap.repl.close()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if
						vim.bo[buf].filetype == "dapui_scopes"
						or vim.bo[buf].filetype == "dapui_breakpoints"
						or vim.bo[buf].filetype == "dapui_stacks"
						or vim.bo[buf].filetype == "dapui_watches"
						or vim.bo[buf].filetype == "dap-repl"
					then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end
			end, { desc = "Close all DAP windows" })

			vim.keymap.set("n", "<Leader>dc", ":DapCloseAll<CR>", { desc = "Close all DAP windows" })

			-- Setup telescope-dap
			require("telescope").load_extension("dap")
		end,
	},
}
