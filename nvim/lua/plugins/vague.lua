return {
	"vague2k/vague.nvim",
	enabled = true,
	config = function()
		require("vague").setup({
			transparent = true,
			bold = true,
			italic = true,
			colors = {
				comment = "#888c90", -- color for comments
				-- comment = "#9a9ea2", -- color for comments
				-- comment = "#b0b4b8", -- color for comments
			},
			plugins = {
				dashboard = {
					footer = "italic",
				},
				lsp = {
					diagnostic_error = "bold",
					diagnostic_hint = "none",
					diagnostic_info = "italic",
					diagnostic_ok = "none",
					diagnostic_warn = "bold",
				},
				cmp = {
					match = "bold",
					match_fuzzy = "bold",
				},
			},
		})
	end,
}
