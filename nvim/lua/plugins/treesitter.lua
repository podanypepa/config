return {
	"nvim-treesitter/nvim-treesitter",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"c",
				"lua",
				"rust",
				"go",
				"gomod",
				"gowork",
				"gosum",
				"vim",
				"vimdoc",
				"json",
				"hjson",
				"yaml",
				"javascript",
				"svelte",
				"bash",
				"typescript",
				"markdown",
				"html",
				"comment",
				"cmake",
				"make",
				"diff",
				"dockerfile",
				"gitcommit",
				"gitignore",
				"pem",
				"python",
				"proto",
			},
			ignore_install = {},
			modules = {},

			sync_install = false,
			auto_install = true,

			highlight = {
				enable = true,
				disable = function(_, buf)
					local max_filesize = 100 * 1024
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
				additional_vim_regex_highlighting = false,
			},
		})
	end,
}
