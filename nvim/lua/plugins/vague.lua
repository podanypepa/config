return {
	"vague2k/vague.nvim",
	enabled = true,
	config = function()
		require("vague").setup({
			transparent = true,
			bold = true,
			italic = true,
		})
	end,
}
