return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- import plugins
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		-- Function to get the Python path from virtual environment
		local get_python_path = function(workspace)
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

		-- Function to print the Python path used by pyright
		local function print_python_path()
			local clients = vim.lsp.get_active_clients()
			for _, client in ipairs(clients) do
				if client.name == "pyright" then
					print("Pyright is using Python interpreter at: " .. client.config.settings.python.pythonPath)
				end
			end
		end

		-- Create user command to print Python path
		vim.api.nvim_create_user_command("PrintPythonPath", print_python_path, {})

		vim.diagnostic.config({
			float = {
				focusable = true,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
				max_width = math.floor(vim.o.columns * 0.6),
				width = 80,
				wrap = true,
			},
			update_in_insert = false,
		})

		vim.api.nvim_create_autocmd("CursorHold", {
			callback = function()
				vim.diagnostic.open_float(nil, { focusable = false, timeout = 4000 })
			end,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				--		local client = vim.lsp.get_client_by_id(ev.data.client_id)

				--		require("illuminate").on_attach(client)

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

				opts.desc = "Open diagnostic in a split"
				vim.keymap.set("n", "<leader>q", function()
					vim.diagnostic.setloclist()
					vim.cmd("lopen")
				end, { desc = "Open diagnostics in a split" })
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		local util = require("lspconfig.util")

		mason_lspconfig.setup_handlers({
			-- default handler for installed servers
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
					root_dir = util.root_pattern("package.json", "tsconfig.json", ".git"),
				})
			end,
			["ts_ls"] = function()
				lspconfig.ts_ls.setup({
					capabilities = cmp_nvim_lsp.default_capabilities(),
					root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
					settings = {
						typescript = {
							suggest = {
								completeFunctionCalls = true,
							},
						},
						javascript = {
							suggest = {
								completeFunctionCalls = true,
							},
						},
					},
				})
			end,
			["biome"] = function()
				lspconfig.biome.setup({
					cmd = { vim.fn.stdpath("data") .. "/mason/bin/biome", "lsp-proxy" },
					filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json" },
					root_dir = lspconfig.util.root_pattern("biome.json", "package.json", ".git"),
					settings = {
						biome = {
							files = {
								exclude = { "node_modules", "dist" },
							},
							formatter = {
								enabled = true,
							},
							lint = {
								enabled = true,
								rules = {
									recommended = true,
								},
							},
						},
					},
				})
			end,
			["svelte"] = function()
				-- configure svelte server
				lspconfig["svelte"].setup({
					capabilities = capabilities,
					root_dir = util.root_pattern("package.json", ".git"),
					on_attach = function(client, bufnr)
						vim.api.nvim_create_autocmd("BufWritePost", {
							pattern = { "*.js", "*.ts" },
							callback = function(ctx)
								client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
							end,
						})
					end,
				})
			end,
			["graphql"] = function()
				-- configure graphql language server
				lspconfig["graphql"].setup({
					capabilities = capabilities,
					filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				})
			end,
			["emmet_ls"] = function()
				-- configure emmet language server
				lspconfig["emmet_ls"].setup({
					capabilities = capabilities,
					root_dir = util.root_pattern("package.json", ".git"),
					filetypes = {
						"html",
						"typescriptreact",
						"javascriptreact",
						"css",
						"sass",
						"scss",
						"less",
						"svelte",
					},
				})
			end,
			["lua_ls"] = function()
				-- configure lua server (with special settings)
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				})
			end,
			["pyright"] = function()
				-- configure pyright server
				lspconfig["pyright"].setup({
					capabilities = capabilities,
					before_init = function(_, config)
						config.settings.python.pythonPath = get_python_path(config.root_dir)
					end,
				})
			end,
		})
	end,
}
