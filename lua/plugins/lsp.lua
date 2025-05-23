return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		{ "williamboman/mason-lspconfig.nvim", version = "*" },
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		local util = require("lspconfig.util")
		local keymap = vim.keymap

		-- Setup Mason
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"ts_ls",
				"pyright",
				"jsonls",
				"emmet_ls",
				"graphql",
				"biome",
				"svelte",
			},
		})

		-- Python venv resolution
		local function get_python_path()
			if vim.env.VIRTUAL_ENV then
				return vim.env.VIRTUAL_ENV .. "/bin/python"
			end
			for _, pattern in ipairs({ "venv", ".venv" }) do
				local match = vim.fn.glob(vim.fn.getcwd() .. "/" .. pattern)
				if match ~= "" then
					return match .. "/bin/python"
				end
			end
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end

		-- Diagnostics float config
		vim.diagnostic.config({
			float = {
				focusable = true,
				style = "minimal",
				border = "rounded",
				source = "always",
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

		-- LSP on-attach keymaps
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				keymap.set("n", "K", vim.lsp.buf.hover, opts)
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
				keymap.set("n", "<leader>q", function()
					vim.diagnostic.setloclist()
					vim.cmd("lopen")
				end, { desc = "Open diagnostics in a split" })
			end,
		})

		-- Diagnostic icons
		for type, icon in pairs({ Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }) do
			vim.fn.sign_define("DiagnosticSign" .. type, { text = icon, texthl = "DiagnosticSign" .. type })
		end

		-- Setup handler-based server configuration
		require("mason-lspconfig").setup({
			-- Default handler
			function(server_name)
				lspconfig[server_name].setup({ capabilities = capabilities })
			end,

			-- TypeScript/JavaScript
			["ts_ls"] = function()
				lspconfig.tsserver.setup({
					capabilities = capabilities,
					root_dir = util.root_pattern("package.json", "tsconfig.json", ".git"),
					settings = {
						typescript = { suggest = { completeFunctionCalls = true } },
						javascript = { suggest = { completeFunctionCalls = true } },
					},
				})
			end,

			-- Lua
			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = { checkThirdParty = false },
							completion = { callSnippet = "Replace" },
						},
					},
				})
			end,

			-- Python
			["pyright"] = function()
				lspconfig.pyright.setup({
					capabilities = capabilities,
					before_init = function(_, config)
						config.settings = config.settings or {}
						config.settings.python = config.settings.python or {}
						config.settings.python.pythonPath = get_python_path()
					end,
				})
			end,

			-- Biome
			["biome"] = function()
				lspconfig.biome.setup({
					cmd = { vim.fn.stdpath("data") .. "/mason/bin/biome", "lsp-proxy" },
					root_dir = util.root_pattern("biome.json", "package.json", ".git"),
					filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json" },
					settings = {
						biome = {
							files = { exclude = { "node_modules", "dist" } },
							formatter = { enabled = true },
							lint = { enabled = true, rules = { recommended = true } },
						},
					},
				})
			end,

			-- GraphQL
			["graphql"] = function()
				lspconfig.graphql.setup({
					capabilities = capabilities,
					filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				})
			end,

			-- Svelte
			["svelte"] = function()
				lspconfig.svelte.setup({
					capabilities = capabilities,
					root_dir = util.root_pattern("package.json", ".git"),
					on_attach = function(client)
						vim.api.nvim_create_autocmd("BufWritePost", {
							pattern = { "*.js", "*.ts" },
							callback = function(ctx)
								client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
							end,
						})
					end,
				})
			end,

			-- Emmet
			["emmet_ls"] = function()
				lspconfig.emmet_ls.setup({
					capabilities = capabilities,
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
		})
	end,
}
