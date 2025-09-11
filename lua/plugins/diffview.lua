-- lua/plugins/diffview.lua
return {
	"sindrets/diffview.nvim",
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewFileHistory",
		"DiffviewFocusFiles",
		"DiffviewLog",
	},
	config = true,
	keys = {
		{ "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", desc = "Git: file history (Diffview)" },
		{ "<leader>gM", "<cmd>DiffviewOpen<CR>", desc = "Git: merge/conflict view" },
	},
}
