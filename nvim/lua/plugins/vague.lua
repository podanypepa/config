return {
	"vague2k/vague.nvim",
	enabled = false,
	config = function()
		require("vague").setup({
			transparent = true,
			bold = true,
			italic = true,
		})
	end,
}
