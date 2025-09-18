-- lua/plugins/dap.lua
return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- Make sure Mason loads first
			"williamboman/mason.nvim",
			"nvim-neotest/nvim-nio",
			{ "rcarriga/nvim-dap-ui" },
			{ "jay-babu/mason-nvim-dap.nvim" },
			{ "mfussenegger/nvim-dap-python" },
			{ "nvim-telescope/telescope-dap.nvim" },
		},
		config = function()
			local dap = require("dap")

			-- Init Mason early so the registry is ready
			require("mason").setup()

			-- Mason DAP bridge
			require("mason-nvim-dap").setup({
				ensure_installed = { "python", "js" }, -- "js" maps to js-debug-adapter
				automatic_installation = true,
			})

			-- Python
			pcall(function()
				require("dap-python").setup("python")
			end)

			-- helper: get visual selection as a single line (non-destructive)
			local function get_visual_selection_text()
				local save_reg, save_type = vim.fn.getreg('"'), vim.fn.getregtype('"')
				vim.cmd('noau normal! "vy')
				local text = vim.fn.getreg('"')
				vim.fn.setreg('"', save_reg, save_type)
				return (text or ""):gsub("\n", " "):gsub("^%s+", ""):gsub("%s+$", "")
			end

			-- add expression to DAP-UI Watches
			local function add_watch(expr)
				if not expr or expr == "" then
					return
				end
				local ok_ui, dapui = pcall(require, "dapui")
				if ok_ui and dapui.elements and dapui.elements.watches and dapui.elements.watches.add then
					dapui.elements.watches.add(expr)
					vim.notify("Watch: " .. expr, vim.log.levels.INFO, { title = "DAP" })
				else
					vim.notify("dap-ui watches API not available", vim.log.levels.WARN, { title = "DAP" })
				end
			end

			local function clear_watches()
				local ok_ui, dapui = pcall(require, "dapui")
				if ok_ui and dapui.elements and dapui.elements.watches then
					dapui.elements.watches.remove()
					vim.notify("All watches cleared", vim.log.levels.INFO, { title = "DAP" })
				end
			end

			-- Robust js-debug path resolution
			local debugger_js
			do
				local mr = require("mason-registry")
				local ok_pkg, pkg = pcall(mr.get_package, "js-debug-adapter")
				if ok_pkg and pkg then
					if not pkg:is_installed() then
						pkg:install()
					end
					local ok_path, install_path = pcall(function()
						return pkg:get_install_path()
					end)
					if ok_path and install_path then
						debugger_js = install_path .. "/js-debug/src/dapDebugServer.js"
					end
				end
			end

			-- Fallback if mason isn’t ready yet (keeps config from crashing)
			if not debugger_js then
				local std = vim.fn.stdpath("data")
				local candidate = std .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
				if vim.loop.fs_stat(candidate) then
					debugger_js = candidate
				end
			end

			-- Only register adapter if we found the server
			if debugger_js then
				dap.adapters["pwa-node"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = { debugger_js, "${port}" },
					},
				}

				dap.configurations.javascript = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = vim.fn.getcwd(),
					},
				}
				dap.configurations.typescript = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch TS file",
						program = "${file}",
						cwd = vim.fn.getcwd(),
						runtimeArgs = { "--loader=ts-node/esm" }, -- tweak if you transpile differently
					},
				}
			end

			-- Keymaps
			local map, opts = vim.keymap.set, { noremap = true, silent = true }

			map("n", "<F5>", function()
				dap.continue()
			end, vim.tbl_extend("force", opts, { desc = "DAP: Continue/Start Debugging" }))

			map("n", "<F10>", function()
				dap.step_over()
			end, vim.tbl_extend("force", opts, { desc = "DAP: Step Over" }))

			map("n", "<F11>", function()
				dap.step_into()
			end, vim.tbl_extend("force", opts, { desc = "DAP: Step Into" }))

			map("n", "<F12>", function()
				dap.step_out()
			end, vim.tbl_extend("force", opts, { desc = "DAP: Step Out" }))

			map("n", "<leader>db", function()
				dap.toggle_breakpoint()
			end, vim.tbl_extend("force", opts, { desc = "DAP: Toggle Breakpoint" }))

			map("n", "<leader>dr", function()
				dap.repl.open()
			end, vim.tbl_extend("force", opts, { desc = "DAP: Open REPL" }))

			map("n", "<F8>", function()
				dap.terminate()
			end, vim.tbl_extend("force", opts, { desc = "DAP: Terminate Debugging" }))

			map("n", "<leader>dc", function()
				local ok_ui, dapui = pcall(require, "dapui")
				if ok_ui then
					dapui.close()
				end
			end, vim.tbl_extend("force", opts, { desc = "DAP: Close UI" }))

			map("n", "<leader>dw", function()
				local word = vim.fn.expand("<cword>")
				add_watch(word)
			end, { desc = "DAP: Add watch (word under cursor)", noremap = true, silent = true })

			-- <leader>dw  (visual): add selected expression
			map("x", "<leader>dw", function()
				local text = get_visual_selection_text()
				add_watch(text)
			end, { desc = "DAP: Add watch (visual selection)", noremap = true, silent = true })

			map("n", "<leader>dWc", clear_watches, { desc = "DAP: Clear all watches", noremap = true, silent = true })

			-- DAP UI: layout + auto-focus REPL (only change requested)
			local ok_ui, dapui = pcall(require, "dapui")
			if ok_ui then
				dapui.setup({
					layouts = {
						{
							position = "left",
							size = 50, -- widened sidebar (columns)
							elements = {
								{ id = "breakpoints", size = 0.15 },
								{ id = "scopes", size = 0.35 },
								{ id = "watches", size = 0.30 },
								{ id = "stacks", size = 0.20 },
							},
						},
						{
							position = "bottom",
							size = 12, -- lines
							elements = {
								{ id = "console", size = 0.40 },
								{ id = "repl", size = 0.60 },
							},
						},
					},
					controls = {
						enabled = true,
						element = "repl",
						icons = {},
						mapping = {},
						indent = 1,
						element_mappings = {},
						force_buffers = false,
					},
					expand_lines = true,
					floating = { border = "rounded" },
					render = { max_type_length = 55 },
				})

				-- replace your existing "dapui_open_focus" listener with this
				dap.listeners.after.event_initialized["dapui_open_focus"] = function()
					local curwin = vim.api.nvim_get_current_win() -- remember code window
					require("dapui").open()
					vim.defer_fn(function()
						if vim.api.nvim_win_is_valid(curwin) then
							vim.api.nvim_set_current_win(curwin) -- restore focus to code
						end
					end, 50)
				end
				-- close UI only on graceful terminate (keep visible on errors)
				dap.listeners.before.event_terminated["dapui_close_ok"] = function(_, body)
					if body and body.exitCode == 0 then
						dapui.close()
					end
				end
				dap.listeners.before.event_exited["dapui_no_close_on_error"] = function() end

				-- quick toggles
				vim.keymap.set("n", "<leader>du", function()
					dapui.toggle()
				end, { desc = "DAP UI: Toggle" })
				vim.keymap.set("n", "<leader>dl", function()
					dapui.toggle({ layout = 1 })
				end, { desc = "DAP UI: Toggle left" })
				vim.keymap.set("n", "<leader>dt", function()
					dapui.toggle({ layout = 2 })
				end, { desc = "DAP UI: Toggle bottom" })
			end

			-- Telescope DAP
			pcall(require("telescope").load_extension, "dap")
		end,
	},
}
