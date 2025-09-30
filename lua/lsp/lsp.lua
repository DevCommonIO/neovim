local M = {}

function M.toggleInlayHints()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end

function M.toggleAutoformat()
	-- Simple autoformat toggle without LazyVim dependency
	vim.g.autoformat = not vim.g.autoformat
	if vim.g.autoformat then
		print("Autoformat enabled")
	else
		print("Autoformat disabled")
	end
end

return M
