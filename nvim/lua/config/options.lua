vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.relativenumber = true
vim.opt.nu = true
vim.opt.hidden = true
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.laststatus = 3
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.opt.wrap = false
vim.g.nohlsearch = true
vim.g.noerrorbells = true
vim.g.novisualbell = true
vim.g.autoindent = true
vim.g.smartindent = true
vim.g.backspace = "indent,eol,start"
vim.g.noswapfile = true
vim.g.nobackup = true
vim.g.nowritebackup = true
vim.g.autowrite = true
vim.g.spliteright = true
vim.g.lazyredraw = true
vim.opt.scrolloff = 4
vim.g.noshowmode = true
vim.g.cmdheight = 2
vim.g.updatetime = 50
vim.g.ttyfast = true
vim.g.confirm = true
vim.g.autoread = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
-- vim.opt.colorcolumn = "80"
vim.g.highlightedyank_highlight_duration = 200
vim.g.netrw_banner = 0
-- vim.g.netrw_winsize = 20
vim.g.netrw_fastbrowse = 0
vim.api.nvim_set_hl(0, "Comment", { italic = true })
vim.o.winborder = "rounded"

vim.opt.guicursor = {
	"n-v-c:block",
	-- "i:ver40",
	"i:block-blinkon100-blinkoff100-blinkwait50",
	"r:hor20",
}
