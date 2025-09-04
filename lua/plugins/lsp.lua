-- lua/plugins/lsp.lua
return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "folke/neodev.nvim", opts = {} }, -- better lua_ls for Neovim
		},
		config = function()
			-- Mason core + LSP bridge
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"pyright",
					"ts_ls", -- JavaScript/TypeScript via new plugin id
				},
			})

			-- Tools: formatters/linters/DAP (installed by Mason)
			local ok_mti, mti = pcall(require, "mason-tool-installer")
			if ok_mti then
				mti.setup({
					ensure_installed = {
						-- formatters
						"prettier", -- js/ts/json/yaml/md
						"black", -- python
						"stylua", -- lua
						-- linters
						"eslint_d", -- js/ts
						-- DAP
						"debugpy", -- python
					},
					auto_update = true,
					run_on_start = true,
				})
			end

			-- Capabilities (nvim-cmp)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp.default_capabilities(capabilities)
			end

			-- on_attach: keymaps + inlay hints
			local on_attach = function(_, bufnr)
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
				end
				map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
				map("n", "gr", vim.lsp.buf.references, "References")
				map("n", "K", vim.lsp.buf.hover, "Hover")
				map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
				map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
				map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")

				local tbuiltin = require("telescope.builtin")
				map("n", "gR", tbuiltin.lsp_references, "References (Telescope)")
				map("n", "gu", tbuiltin.lsp_references, "Usages (Telescope)")

				if vim.lsp.inlay_hint then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end

			local lsp = require("lspconfig")

			-- lua_ls
			lsp.lua_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						diagnostics = { globals = { "vim" } },
						format = { enable = false }, -- use stylua via formatter plugin
					},
				},
			})

			-- pyright
			lsp.pyright.setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})

			-- ts_ls (TypeScript/JavaScript/React)
			lsp.ts_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				},
				filetypes = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
			})

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
				float = {
					border = "rounded",
					source = "always",
					header = "",
				},
			})
		end,
	},
}
