vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.swapfile = false
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"

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
})

vim.lsp.enable({ "lua_ls", "svelte-language-server" })

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
