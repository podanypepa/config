vim.opt.background = "dark"
vim.cmd("colorscheme vague")

-- vim.cmd("colorscheme black-metal-day")
-- vim.o.background = "dark"

-- vim.cmd("colorscheme default")
-- vim.api.nvim_set_hl(0, "Comment", { fg = "#9b9fa3" })

vim.api.nvim_set_hl(0, "Normal", { bg = nil })
vim.api.nvim_set_hl(0, "CursorLine", { bg = nil })
vim.api.nvim_set_hl(0, "CursorLineNr", { bg = nil, fg = "white" })
vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })

vim.api.nvim_set_hl(0, "MojeBarvaSouboru", { fg = "#00ff00", bg = nil, bold = false })
vim.opt.statusline = "%#MojeBarvaSouboru# %f %*"
