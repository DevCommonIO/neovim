return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- Function to get the Python path from virtual environment
		local get_python_path = function(workspace)
			-- Check for a .venv file
			local venv = workspace .. "/.venv"
			local venv_file = io.open(venv, "r")
			if venv_file then
				local venv_path = venv_file:read()
				venv_file:close()
				return venv_path .. "/bin/python"
			end
			-- Use activated virtualenv.
			if vim.env.VIRTUAL_ENV then
				return vim.env.VIRTUAL_ENV .. "/bin/python"
			end
			-- Find and use virtualenv in workspace directory.
			for _, pattern in ipairs({ "venv", ".venv" }) do
				local match = vim.fn.glob(vim.fn.getcwd() .. "/" .. pattern)
				if match ~= "" then
					return match .. "/bin/python"
				end
			end
			-- Fallback to system Python.
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"graphql",
				"emmet_ls",
				"prismals",
				"pyright",
			},
			automatic_installation = true,
			handlers = {
				-- default handler for installed servers
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,
				["pyright"] = function()
					require("lspconfig").pyright.setup({
						before_init = function(_, config)
							config.settings.python.pythonPath = get_python_path(config.root_dir)
						end,
						settings = {
							python = {
								analysis = {
									autoSearchPaths = true,
									useLibraryCodeForTypes = true,
								},
							},
						},
					})
				end,
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint", -- python linter
				-- "eslint_d", -- js linter
				"eslint",
			},
		})
	end,
}
