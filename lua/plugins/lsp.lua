return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre" },

	dependencies = {
		"williamboman/mason.nvim",
		{ "williamboman/mason-lspconfig.nvim", version = ">=2.0.0" },
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local util = require("lspconfig.util")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		---------------------------------------------------------------------------
		-- Capabilities
		---------------------------------------------------------------------------
		local capabilities = cmp_nvim_lsp.default_capabilities()
		capabilities.textDocument.semanticTokens = {
			dynamicRegistration = false,
			requests = { range = true, full = true },
			tokenTypes = {},
			tokenModifiers = {},
			formats = { "relative" },
			multilineTokenSupport = false,
			overlappingTokenSupport = false,
		}

		---------------------------------------------------------------------------
		-- Helpers
		---------------------------------------------------------------------------
		local function enable_semantic_tokens(client, bufnr)
			if client and client.server_capabilities.semanticTokensProvider then
				vim.lsp.semantic_tokens.start(bufnr, client.id)
			end
		end

		-- If you’re using Conform/Prettier/etc., keep LSP formatting off by default.
		local function disable_formatting(client)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
		end

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

		---------------------------------------------------------------------------
		-- Diagnostics UI
		---------------------------------------------------------------------------
		vim.diagnostic.config({
			virtual_text = { prefix = "●", source = "if_many", spacing = 2 },
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = {
				focusable = true,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})

		for type, icon in pairs({ Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }) do
			vim.fn.sign_define("DiagnosticSign" .. type, { text = icon, texthl = "DiagnosticSign" .. type })
		end

		-- Show diagnostic float on hold (quiet, non-stealing focus)
		vim.api.nvim_create_autocmd("CursorHold", {
			pattern = "*",
			callback = function()
				vim.diagnostic.open_float(nil, { focus = false })
			end,
		})

		---------------------------------------------------------------------------
		-- on_attach: keymaps + semantic tokens + (optional) formatting off
		---------------------------------------------------------------------------
		local function on_attach(client, bufnr)
			enable_semantic_tokens(client, bufnr)
			disable_formatting(client) -- comment out if you want LSP formatting

			local opts = { buffer = bufnr, silent = true }
			local keymap = vim.keymap
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
		end

		---------------------------------------------------------------------------
		-- Mason
		---------------------------------------------------------------------------
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
			automatic_installation = true,
		})

		---------------------------------------------------------------------------
		-- Servers
		---------------------------------------------------------------------------
		-- TypeScript / JavaScript (keep it simple)
		lspconfig.ts_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = {
				"typescript",
				"typescriptreact",
				"typescript.tsx",
				"javascript",
				"javascriptreact",
				"javascript.jsx",
			},
			root_dir = function(fname)
				local root = util.root_pattern("tsconfig.json")(fname)
					or util.root_pattern("package.json", ".git")(fname)
				return root or vim.fn.getcwd()
			end,
			settings = {
				typescript = {
					suggest = { completeFunctionCalls = true },
					preferences = {
						preferGoToSourceDefinition = true, -- 👈 key fix
					},
				},
				javascript = {
					suggest = { completeFunctionCalls = true },
					preferences = {
						preferGoToSourceDefinition = true, -- 👈 for JS/JSX too
					},
				},
			},
			flags = { debounce_text_changes = 150 },
		})
		-- lspconfig.ts_ls.setup({
		-- 	capabilities = capabilities,
		-- 	on_attach = on_attach,
		-- 	filetypes = {
		-- 		"typescript",
		-- 		"typescriptreact",
		-- 		"typescript.tsx",
		-- 		"javascript",
		-- 		"javascriptreact",
		-- 		"javascript.jsx",
		-- 	},
		-- 	root_dir = function(fname)
		-- 		-- Prefer nearest tsconfig.json; fallback to package.json or .git or CWD
		-- 		local root = util.root_pattern("tsconfig.json")(fname)
		-- 			or util.root_pattern("package.json", ".git")(fname)
		-- 		if not root then
		-- 			vim.schedule(function()
		-- 				vim.notify("[ts_ls] No project root found. Using CWD", vim.log.levels.WARN)
		-- 			end)
		-- 			return vim.fn.getcwd()
		-- 		end
		-- 		return root
		-- 	end,
		-- 	settings = {
		-- 		typescript = { suggest = { completeFunctionCalls = true } },
		-- 		javascript = { suggest = { completeFunctionCalls = true } },
		-- 	},
		-- 	flags = { debounce_text_changes = 150 },
		-- })
		--
		-- Lua
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "vim" } },
					workspace = { checkThirdParty = false },
					completion = { callSnippet = "Replace" },
				},
			},
		})

		-- Python
		lspconfig.pyright.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			before_init = function(_, config)
				config.settings = config.settings or {}
				config.settings.python = config.settings.python or {}
				config.settings.python.pythonPath = get_python_path()
			end,
		})

		-- JSON via Biome LSP proxy (only for JSON)
		lspconfig.biome.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			cmd = { vim.fn.stdpath("data") .. "/mason/bin/biome", "lsp-proxy" },
			root_dir = util.root_pattern("biome.json", "package.json", ".git"),
			filetypes = { "json" },
			settings = {
				biome = {
					files = { exclude = { "node_modules", "dist" } },
					formatter = { enabled = true },
					lint = { enabled = true, rules = { recommended = true } },
				},
			},
		})

		-- GraphQL
		lspconfig.graphql.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})

		-- Svelte
		lspconfig.svelte.setup({
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				on_attach(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
					end,
				})
			end,
			root_dir = util.root_pattern("package.json", ".git"),
		})

		-- Emmet
		lspconfig.emmet_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
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
}
