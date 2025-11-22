return {
	"navarasu/onedark.nvim",
	priority = 1000,
	config = function()
		require("onedark").setup({
			style = "light",
		})
		require("onedark").load()
	end,
}
