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

			-- Robust js-debug path resolution
			local debugger_js
			do
				local mr = require("mason-registry")
				local ok_pkg, pkg = pcall(mr.get_package, "js-debug-adapter")
				if ok_pkg and pkg then
					if not pkg:is_installed() then
						-- optional: install synchronously; or just skip until installed
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

			map("n", "<F8>", function()
				dap.terminate()
			end, opts)

			-- Close all dap-ui windows (<leader>dc)
			map("n", "<leader>dc", function()
				local ok_ui, dapui = pcall(require, "dapui")
				if ok_ui then
					dapui.close()
				end
			end, opts)

			-- dap-ui
			-- local ok_ui, dapui = pcall(require, "dapui")
			-- if ok_ui then
			-- 	dapui.setup()
			-- 	dap.listeners.after.event_initialized["dapui_config"] = function()
			-- 		dapui.open()
			-- 	end
			-- 	dap.listeners.before.event_terminated["dapui_config"] = function()
			-- 		dapui.close()
			-- 	end
			-- 	dap.listeners.before.event_exited["dapui_config"] = function()
			-- 		dapui.close()
			-- 	end
			-- end
			--
			local ok_ui, dapui = pcall(require, "dapui")
			if ok_ui then
				dapui.setup()

				-- open UI when debugging starts
				dap.listeners.after.event_initialized["dapui_config"] = function()
					dapui.open()
				end

				-- close UI only on graceful terminate (exitCode == 0)
				dap.listeners.before.event_terminated["dapui_config"] = function(_, body)
					if body and body.exitCode == 0 then
						dapui.close()
					end
				end

				-- don’t auto-close on event_exited so UI stays visible on errors
				-- dap.listeners.before.event_exited["dapui_config"] = function() end
			end

			-- Telescope DAP
			pcall(require("telescope").load_extension, "dap")
		end,
	},
}
