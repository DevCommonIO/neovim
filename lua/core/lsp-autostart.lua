-- Auto-start ts_ls if not already running
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
	once = true,
	callback = function()
		local clients = vim.lsp.get_active_clients({ name = "ts_ls" })
		if vim.tbl_isempty(clients) then
			vim.cmd("LspStart ts_ls")
		end
	end,
})
