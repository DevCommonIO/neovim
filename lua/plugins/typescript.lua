return {
	"jose-elias-alvarez/typescript.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
	},
	ft = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact" },
	config = function()
		local typescript = require("typescript")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		typescript.setup({
			server = {
				capabilities = cmp_nvim_lsp.default_capabilities(),
				root_dir = require("lspconfig.util").root_pattern("package.json", "tsconfig.json", ".git"),
				on_attach = function(client, bufnr)
					local keymap = vim.keymap
					local opts = { buffer = bufnr, silent = true }

					-- Basic LSP mappings
					keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
					keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
					keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
					keymap.set("n", "K", vim.lsp.buf.hover, opts)
					keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

					-- TypeScript-specific commands
					keymap.set(
						"n",
						"<leader>lo",
						":TypescriptOrganizeImports<CR>",
						{ buffer = bufnr, desc = "Organize Imports" }
					)
					keymap.set("n", "<leader>lf", ":TypescriptFixAll<CR>", { buffer = bufnr, desc = "Fix All" })
					keymap.set(
						"n",
						"<leader>lu",
						":TypescriptRemoveUnused<CR>",
						{ buffer = bufnr, desc = "Remove Unused" }
					)
					keymap.set(
						"n",
						"<leader>la",
						":TypescriptAddMissingImports<CR>",
						{ buffer = bufnr, desc = "Add Missing Imports" }
					)

					-- Optional: Disable formatting if using Biome/Prettier
					client.server_capabilities.documentFormattingProvider = false
				end,
			},
		})

		-- Optional: Restore :LspFixAll as an alias
		vim.api.nvim_create_user_command("LspFixAll", function()
			vim.cmd("TypescriptFixAll")
		end, {})
	end,
}
