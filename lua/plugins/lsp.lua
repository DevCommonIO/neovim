return {
	"neovim/nvim-lspconfig",
	-- event = { "BufReadPre", "BufNewFile" },
	event = { "BufReadPre" },
	dependencies = {
		"williamboman/mason.nvim",
		{
			"williamboman/mason-lspconfig.nvim",
			version = ">=2.0.0",
		},
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		{
			"folke/tokyonight.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				require("tokyonight").setup({
					style = "moon",
					transparent = false,
					styles = {
						comments = { italic = true },
						keywords = { italic = false },
						functions = { bold = true },
					},
				})
				vim.cmd.colorscheme("tokyonight")
			end,
		},
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()
		local util = require("lspconfig.util")
		local keymap = vim.keymap

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "typescriptreact",
			callback = function()
				print("FileType is correctly set to typescriptreact")
			end,
		})

		-- ✅ Add semantic token capabilities
		capabilities.textDocument.semanticTokens = {
			dynamicRegistration = false,
			requests = {
				range = true,
				full = true,
			},
			tokenTypes = {},
			tokenModifiers = {},
			formats = { "relative" },
			multilineTokenSupport = false,
			overlappingTokenSupport = false,
		}

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
			automatic_installation = true,
		})

		-- 🧠 Enable semantic highlighting per buffer
		local function enable_semantic_tokens(client, bufnr)
			if client.server_capabilities.semanticTokensProvider then
				vim.lsp.semantic_tokens.start(bufnr, client.id)
			end
		end

		-- Python virtualenv logic
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

		-- ✅ Inline + float diagnostics
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●",
				source = "if_many",
				spacing = 2,
			},
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

		-- ✅ Show float on cursor hold
		vim.api.nvim_create_autocmd("CursorHold", {
			pattern = "*",
			callback = function()
				vim.diagnostic.open_float(nil, { focus = false })
			end,
		})

		-- LSP keymaps on attach
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				enable_semantic_tokens(client, ev.buf)

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

		-- Diagnostic signs
		for type, icon in pairs({ Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }) do
			vim.fn.sign_define("DiagnosticSign" .. type, { text = icon, texthl = "DiagnosticSign" .. type })
		end

		-- Server configs below...
		-- lspconfig.ts_ls.setup({
		-- 	capabilities = capabilities,
		-- 	root_dir = util.root_pattern("package.json", "tsconfig.json", ".git"),
		--
		-- 	filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "json" },
		-- 	settings = {
		-- 		typescript = { suggest = { completeFunctionCalls = true } },
		-- 		javascript = { suggest = { completeFunctionCalls = true } },
		-- 	},
		-- })
		--
		-- Server configs below...
		lspconfig.ts_ls.setup({
			capabilities = capabilities,
			filetypes = {
				"typescript",
				"typescriptreact",
				"typescript.tsx",
				"javascript",
				"javascriptreact",
				"javascript.jsx",
			},
			root_dir = function(fname)
				local root = util.root_pattern("package.json", "tsconfig.json", ".git")(fname)
				if not root then
					vim.schedule(function()
						vim.notify("[ts_ls] No project root found. Falling back to CWD", vim.log.levels.WARN)
					end)
					return vim.fn.getcwd()
				end

				vim.schedule(function()
					vim.notify("[ts_ls] root_dir = " .. root, vim.log.levels.INFO)
				end)

				return root
			end,
			settings = {
				typescript = {
					suggest = { completeFunctionCalls = true },
				},
				javascript = {
					suggest = { completeFunctionCalls = true },
				},
			},
		})

		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "vim" } },
					workspace = { checkThirdParty = false },
					completion = { callSnippet = "Replace" },
				},
			},
		})

		lspconfig.pyright.setup({
			capabilities = capabilities,
			before_init = function(_, config)
				config.settings = config.settings or {}
				config.settings.python = config.settings.python or {}
				config.settings.python.pythonPath = get_python_path()
			end,
		})

		lspconfig.biome.setup({
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

		lspconfig.graphql.setup({
			capabilities = capabilities,
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})

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
}
