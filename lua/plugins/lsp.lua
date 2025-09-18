-- lua/plugins/lsp.lua
return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "folke/neodev.nvim", opts = {} }, -- better lua_ls for Neovim
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Mason core + bridge
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"pyright",
					"ts_ls", -- new lspconfig id for TS/JS
				},
			})

			-- Ensure common tools (formatters/linters/dap)
			local ok_mti, mti = pcall(require, "mason-tool-installer")
			if ok_mti then
				mti.setup({
					ensure_installed = {
						-- formatters
						"prettier",
						"black",
						"stylua",
						-- linters
						"eslint_d",
						-- DAP
						"debugpy",
					},
					auto_update = true,
					run_on_start = true,
				})
			end

			-- Capabilities (cmp)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp.default_capabilities(capabilities)
			end

			-- Highlight appearance + responsiveness
			vim.api.nvim_set_hl(0, "LspReferenceText", { underline = true })
			vim.api.nvim_set_hl(0, "LspReferenceRead", { underline = true })
			vim.api.nvim_set_hl(0, "LspReferenceWrite", { underline = true })
			vim.o.updatetime = 250

			-- Global diagnostics look & behavior
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					spacing = 2,
					source = "if_many",
					severity = { min = vim.diagnostic.severity.WARN },
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = { border = "rounded", source = "always", header = "" },
			})

			-- on_attach: keymaps, toggle inlay hints, document highlights
			local on_attach = function(client, bufnr)
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
				end

				local tb = require("telescope.builtin")

				-- LSP navigation (use Telescope where it helps)
				map("n", "gd", tb.lsp_definitions, "Goto Definition")
				map("n", "gr", vim.lsp.buf.references, "References")
				map("n", "gR", tb.lsp_references, "References (Telescope)")
				map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
				map("n", "gy", vim.lsp.buf.type_definition, "Goto Type Definition")

				-- LSP actions
				map("n", "K", vim.lsp.buf.hover, "Hover")
				map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
				map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
				map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")

				-- Toggle inlay hints (global toggle)
				map("n", "<leader>h", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
				end, "Toggle inlay hints")

				-- Highlight all references to symbol under cursor
				if client.supports_method("textDocument/documentHighlight") then
					local grp = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })

					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						group = grp,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.document_highlight()
						end,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
						group = grp,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.clear_references()
						end,
					})
				end
			end

			-- Servers
			local lsp = require("lspconfig")

			-- lua_ls
			lsp.lua_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						diagnostics = { globals = { "vim" } },
						format = { enable = false }, -- use stylua
					},
				},
			})

			-- pyright
			lsp.pyright.setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})

			-- ts_ls (TypeScript/JavaScript/React)
			-- Disable inlay hints at the server so they don't appear
			lsp.ts_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				init_options = {
					preferences = {
						includeInlayParameterNameHints = "none",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = false,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = false,
						includeInlayFunctionLikeReturnTypeHints = false,
						includeInlayEnumMemberValueHints = false,
					},
				},
				filetypes = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
			})
		end,
	},
}
