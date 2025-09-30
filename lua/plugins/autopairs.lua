-- lua/plugins/autopairs.lua
return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		check_ts = true, -- use treesitter to avoid pairing inside strings etc.
		disable_filetype = { "TelescopePrompt", "vim" },
		map_cr = true, -- map <CR> to expand pairs
		map_bs = true, -- backspace deletes pair if needed
		fast_wrap = {
			map = "<M-e>",
			chars = { "{", "[", "(", '"', "'" },
			pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
			end_key = "$",
			keys = "qwertyuiopzxcvbnmasdfghjkl",
			highlight = "Search",
			highlight_grey = "LineNr",
		},
	},
	config = function(_, opts)
		local npairs = require("nvim-autopairs")
		npairs.setup(opts)

		-- integration with cmp
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local ok, cmp = pcall(require, "cmp")
		if ok then
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
		end
	end,
}
