return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		{
			"williamboman/mason-lspconfig.nvim",
			version = ">=2.0.0",
		},
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		{ -- ✅ Added TokyoNight colorscheme
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
				-- "tsserver",
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

		-- LSP diagnostics float config
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

		-- LSP keymaps on attach
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				enable_semantic_tokens(client, ev.buf)

				local opts = { buffer = ev.buf, silent = true }
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				-- Remap gD to just fallback to definitions
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
			filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json" },
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
