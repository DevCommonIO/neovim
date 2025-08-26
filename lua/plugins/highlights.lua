return {
	"andymass/vim-matchup",
	event = "VeryLazy",
	init = function()
		-- Show matching pair even if it's offscreen
		vim.g.matchup_matchparen_offscreen = {
			method = "popup", -- try also: "status", "scroll"
		}

		-- Highlight inside matches (e.g., inside `()`)
		vim.g.matchup_matchparen_deferred = 1
		vim.g.matchup_matchparen_hi_surround_always = 1
		vim.g.matchup_matchparen_enabled = 1

		-- Enable matchup for all filetypes
		vim.g.matchup_enabled = 1
	end,
}
