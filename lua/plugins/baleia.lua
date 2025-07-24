return {
	"m00qek/baleia.nvim",
	event = { "BufReadPost" },
	config = function()
		local baleia = require("baleia").setup()

		vim.api.nvim_create_user_command("BaleiaColorize", function()
			baleia.once(vim.api.nvim_get_current_buf())
		end, {})

		vim.api.nvim_create_autocmd({ "BufReadPost" }, {
			pattern = { "*.log", "*.txt" },
			callback = function()
				baleia.once(0)
			end,
		})
	end,
}
