-- lua/plugins/git-conflict.lua
return {
	"akinsho/git-conflict.nvim",
	version = "*",
	event = "BufReadPre",
	config = function()
		require("git-conflict").setup({
			default_mappings = true, -- enables:
			-- ]x / [x  -> next/prev conflict
			-- co      -> choose ours
			-- ct      -> choose theirs
			-- cb      -> choose both
			-- c0      -> choose none
		})
	end,
	keys = {
		{ "]x", desc = "Next conflict" },
		{ "[x", desc = "Prev conflict" },
		{ "co", desc = "Choose ours", mode = "n" },
		{ "ct", desc = "Choose theirs", mode = "n" },
		{ "cb", desc = "Choose both", mode = "n" },
		{ "c0", desc = "Choose none", mode = "n" },
	},
}
