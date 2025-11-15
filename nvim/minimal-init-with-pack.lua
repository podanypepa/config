vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.swapfile = false
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"
vim.opt.ignorecase = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.undofile = false
vim.opt.incsearch = true
vim.g.mapleader = " "

vim.packadd({
	{
		src = "https://github.com/vague2k/vague.nvim",
	},
	{
		src = "https://github.com/stevearc/oil.nvim",
	},
	{
		src = "https://github.com/neovim/nvim-lspconfig",
	},
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
	},
	{
		src = "https://github.com/mason-org/mason.nvim",
	},
	{
		src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
	},
	{
		"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	},
})

require("mason").setup()
require("render-markdown").setup({})

vim.lsp.enable({ "lua_ls", "svelte-language-server" })
vim.lsp.config.lua_ls.setup({
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
		},
	},
})
require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "svelte", "javascript", "typescript", "html", "css" },
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})

vim.colorscheme = "vague"
-- vim.cmd.colorscheme("vague")

vim.cmd("hi statusliene guibg=None")

require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})

vim.keymap.set("n", "<leader>o", ":update<CR> :source %<CR>")
vim.keymap.set("n", "<leader>ff", vim.cmd.Ex)
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>q", ":quit<CR>")
vim.keymap.set("n", "<leader>lw", vim.lsp.buf.format)
