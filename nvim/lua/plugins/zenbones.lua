return {
	"zenbones-theme/zenbones.nvim",
	dependencies = "rktjmp/lush.nvim",
	enabled = false,
	lazy = false,
	priority = 1000,
	config = function()
		vim.g.zenbones_darken_comments = 55
		vim.opt.background = "light"
		vim.cmd.colorscheme("zenbones")
	end,
}
