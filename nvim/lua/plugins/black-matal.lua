return -- Using lazy.nvim
{
	"metalelf0/black-metal-theme-neovim",
	lazy = false,
	priority = 1000,
	enabled = false,
	config = function()
		require("black-metal").setup({
			-- Can be one of: bathory | burzum | dark-funeral | darkthrone | emperor | gorgoroth | immortal | impaled-nazarene | khold | marduk | mayhem | nile | taake | thyrfing | venom | windir
			theme = "darkthrone",
			-- Can be one of: 'light' | 'dark', or set via vim.o.background
			variant = "dark",
			-- optional configuration here
		})
		require("black-metal").load()
	end,
}
