vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.netrw_banner = 0
vim.g.netrw_fastbrowse = 0

vim.opt.relativenumber = true
vim.opt.nu = true
vim.opt.hidden = true
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.laststatus = 3
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
vim.opt.hlsearch = true
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.backspace = "indent,eol,start"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.autowrite = true
vim.opt.splitright = true
vim.opt.showmode = false
vim.opt.cmdheight = 1
vim.opt.updatetime = 50
vim.opt.confirm = true
vim.opt.autoread = true
vim.opt.autowrite = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.winborder = "rounded"
vim.opt.lazyredraw = true

vim.opt.guicursor = {
	"n-v-c:block",
	"i:block-blinkon100-blinkoff100-blinkwait50",
	"r:hor20",
}

vim.api.nvim_set_hl(0, "Comment", { italic = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 400 })
	end,
})

local gh = function(x)
	return "https://github.com/" .. x
end

vim.pack.add({
	gh("stevearc/oil.nvim"),
	gh("nvim-tree/nvim-web-devicons"),
	gh("vague2k/vague.nvim"),
	gh("nvim-lua/plenary.nvim"),
	gh("sindrets/diffview.nvim"),
	gh("ibhagwan/fzf-lua"),
	gh("NeogitOrg/neogit"),
	gh("hrsh7th/nvim-cmp"),
	gh("hrsh7th/cmp-nvim-lsp"),
	gh("hrsh7th/cmp-buffer"),
	gh("hrsh7th/cmp-path"),
	gh("hrsh7th/cmp-cmdline"),
	gh("onsails/lspkind.nvim"),
	gh("L3MON4D3/LuaSnip"),
	gh("skywind3000/asyncrun.vim"),
	gh("zbirenbaum/copilot.lua"),
	gh("zbirenbaum/copilot-cmp"),
	gh("mhartington/formatter.nvim"),
	gh("windwp/nvim-autopairs"),
	gh("lewis6991/gitsigns.nvim"),
	gh("mfussenegger/nvim-dap"),
	gh("nvim-neotest/nvim-nio"),
	gh("rcarriga/nvim-dap-ui"),
	gh("leoluz/nvim-dap-go"),
	gh("theHamsta/nvim-dap-virtual-text"),
	gh("neovim/nvim-lspconfig"),
	gh("mason-org/mason.nvim"),
	gh("mason-org/mason-lspconfig.nvim"),
})

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "gopls", "pyright", "lua_ls" },
})

-- parsers (Go)
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/treesitter")

local parser_dir = vim.fn.stdpath("data") .. "/treesitter/parser/"
for _, lang in ipairs({ "go", "gomod", "gowork", "gosum" }) do
	vim.treesitter.language.add(lang, { path = parser_dir .. lang .. ".so" })
end
-- query files pro Go (highlights.scm atd.) jsou v nvim-treesitter
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site/pack/core/opt/nvim-treesitter")

local ts_langs = { go = "go", gomod = "gomod", gowork = "gowork", gosum = "gosum", python = "python" }
vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(ts_langs),
	callback = function(ev)
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
		if ok and stats and stats.size > 100 * 1024 then
			return
		end
		vim.treesitter.start(ev.buf, ts_langs[vim.bo[ev.buf].filetype])
	end,
})

require("oil").setup({
	confirm = false,
	skip_confirm_for_simple_edits = true,
	prompt_save_on_select_new_entry = false,
	default_file_explorer = true,
	float = {
		preview_split = "left",
	},
	columns = {
		"icon",
	},
	cleanup_delay_ms = 2000,
	watch_for_changes = true,
	view_options = {
		show_hidden = true,
		is_always_hidden = function(name, _)
			local folder_skip = { "dev-tools.locks", "dune.lock", "_build", ".git", ".DS_Store" }
			return vim.tbl_contains(folder_skip, name)
		end,
		natural_order = "fast",
		case_insensitive = false,
		sort = {
			{ "type", "asc" },
			{ "name", "asc" },
		},
	},
	preview_win = {
		preview_split = "above",
		update_on_cursor_moved = true,
		preview_method = "fast_scratch",
		win_options = {},
	},
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("vague").setup({
	transparent = true,
	bold = true,
	italic = true,
	colors = {
		comment = "#888c90",
	},
	plugins = {
		lsp = {
			diagnostic_error = "bold",
			diagnostic_hint = "none",
			diagnostic_info = "italic",
			diagnostic_ok = "none",
			diagnostic_warn = "bold",
		},
		cmp = {
			match = "bold",
			match_fuzzy = "bold",
		},
	},
})

vim.opt.background = "dark"
vim.cmd("colorscheme vague")

vim.api.nvim_set_hl(0, "Search", { bg = "#8b0000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#ff0000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "Normal", { bg = nil })
vim.api.nvim_set_hl(0, "CursorLine", { bg = nil })
vim.api.nvim_set_hl(0, "CursorLineNr", { bg = nil, fg = "white" })
vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
vim.api.nvim_set_hl(0, "YankHighlight", { fg = "#ffffff", bg = "#8b0000" })
vim.api.nvim_set_hl(0, "MojeBarvaSouboru", { fg = "#00ff00", bg = nil, bold = false })
vim.opt.statusline = "%#MojeBarvaSouboru# %f %*"
vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "NONE" })
vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "NONE" })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "NONE" })

vim.lsp.enable("gopls")
vim.lsp.enable("pyright")
vim.lsp.enable("lua_ls")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
			vim.keymap.set("i", "<C-Space>", function()
				vim.lsp.completion.get()
			end)
		end
	end,
})

vim.diagnostic.config({
	virtual_lines = true,
	signs = true,
	update_in_insert = true,
	float = {
		header = false,
		border = "single",
		focusable = true,
		source = true,
		prefix = "",
	},
	underline = false,
	severity_sort = true,
})

require("nvim-autopairs").setup()

require("gitsigns").setup({
	signs = {
		add = { text = "┃" },
		change = { text = "┃" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signcolumn = true,
	numhl = true,
	linehl = false,
	word_diff = false,
	watch_gitdir = { follow_files = true },
	auto_attach = true,
	attach_to_untracked = true,
	current_line_blame_formatter = "<summary>",
	sign_priority = 6,
	update_debounce = 100,
	max_file_length = 40000,
	preview_config = {
		border = "single",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
})


require("fzf-lua").setup({
	fzf_colors = true,
	files = {
		cmd = "fd --type f --hidden --no-ignore --exclude .git",
	},
	file_icon_padding = " ",
	previewers = {
		builtin = {
			syntax_limit_b = -102400,
		},
	},
	winopts = {
		preview = {
			layout = "vertical",
			title = true,
			title_pos = "left",
		},
	},
})

require("neogit").setup({
	commit_view = {
		kind = "split",
		verify_commit = vim.fn.executable("gpg") == 1,
	},
	highlight = {
		italic = true,
		bold = true,
		underline = true,
	},
	auto_refresh = true,
	sort_branches = "-committerdate",
	disable_line_numbers = true,
	auto_show_console = true,
	auto_close_console = true,
})

require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})
require("copilot_cmp").setup()

local cmp = require("cmp")
local cmp_select_opts = { behavior = cmp.SelectBehavior.Select }
local lspkind = require("lspkind")

cmp.setup({
	enabled = true,
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<C-e>"] = cmp.mapping.abort(),
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		["<Up>"] = cmp.mapping.select_prev_item(cmp_select_opts),
		["<Down>"] = cmp.mapping.select_next_item(cmp_select_opts),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<C-p>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.select_prev_item(cmp_select_opts)
			else
				cmp.complete()
			end
		end),
		["<C-n>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.select_next_item(cmp_select_opts)
			else
				cmp.complete()
			end
		end),
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	sources = cmp.config.sources({
		{ name = "copilot" },
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "path" },
	}, {
		{ name = "buffer" },
	}),
	formatting = {
		format = lspkind.cmp_format({
			maxwidth = 50,
			ellipsis_char = "...",
		}),
	},
})

local util = require("formatter.util")
require("formatter").setup({
	logging = true,
	log_level = vim.log.levels.WARN,
	filetype = {
		go = {
			require("formatter.filetypes.go").gofumpt,
		},
		rust = {
			require("formatter.filetypes.rust").rustfmt,
		},
		json = {
			function()
				return {
					exe = "jq",
					args = { "--indent 4", "." },
					stdin = true,
				}
			end,
		},
		javascript = {
			require("formatter.filetypes.javascript").prettier,
		},
		svelte = {
			require("formatter.filetypes.javascript").prettier,
		},
		typescript = {
			require("formatter.filetypes.typescript").prettier,
		},
		html = {
			require("formatter.filetypes.html").prettier,
		},
		css = {
			require("formatter.filetypes.css").prettier,
		},
		zig = {
			function()
				return {
					exe = "zig",
					args = { "fmt", "." },
					stdin = true,
				}
			end,
		},
		python = {
			require("formatter.filetypes.python").black,
		},
		lua = {
			require("formatter.filetypes.lua").stylua,
			function()
				if util.get_current_buffer_file_name() == "special.lua" then
					return nil
				end
				return {
					exe = "stylua",
					args = {
						"--search-parent-directories",
						"--stdin-filepath",
						util.escape_path(util.get_current_buffer_file_path()),
						"--",
						"-",
					},
					stdin = true,
				}
			end,
		},
		["*"] = {
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
	},
})

vim.api.nvim_create_augroup("__formatter__", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = "__formatter__",
	command = ":FormatWrite",
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		local client = vim.lsp.get_clients({ bufnr = 0 })[1]
		local enc = client and client.offset_encoding or "utf-16"
		local params = vim.lsp.util.make_range_params(0, enc)
		params.context = { only = { "source.organizeImports" }, diagnostics = {} }
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
		for cid, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
					vim.lsp.util.apply_workspace_edit(r.edit, enc)
				elseif r.command then
					vim.lsp.buf.execute_command(r.command)
				end
			end
		end
	end,
})

-- LSP
vim.keymap.set("n", "gt", function()
	vim.lsp.buf.type_definition()
end)
vim.keymap.set("n", "gT", function()
	local client = vim.lsp.get_clients({ bufnr = 0 })[1]
	local enc = client and client.offset_encoding or "utf-16"
	local params = vim.lsp.util.make_position_params(0, enc)
	vim.lsp.buf_request(0, "textDocument/typeDefinition", params, function(err, result)
		if err or not result or vim.tbl_isempty(result) then
			vim.notify("No type definition found", vim.log.levels.INFO)
			return
		end
		local loc = vim.islist(result) and result[1] or result
		local uri = loc.uri or loc.targetUri
		local range = loc.range or loc.targetSelectionRange
		local start_line = range.start.line

		local tbufnr = vim.uri_to_bufnr(uri)
		vim.fn.bufload(tbufnr)

		local all_lines = vim.api.nvim_buf_get_lines(tbufnr, start_line, -1, false)

		-- najdi konec definice typu (matching closing brace)
		local end_idx = #all_lines
		local depth, found_open = 0, false
		for i, line in ipairs(all_lines) do
			for c in line:gmatch(".") do
				if c == "{" then
					depth = depth + 1
					found_open = true
				elseif c == "}" then
					depth = depth - 1
				end
			end
			if found_open and depth == 0 then
				end_idx = i
				break
			end
		end

		local def_lines = vim.list_slice(all_lines, 1, end_idx)

		local function line_display_width(line)
			local w = 0
			for i = 1, #line do
				if line:sub(i, i) == "\t" then
					w = w + vim.o.tabstop - (w % vim.o.tabstop)
				else
					w = w + 1
				end
			end
			return w
		end

		local width = 0
		for _, l in ipairs(def_lines) do
			width = math.max(width, line_display_width(l))
		end
		width = math.min(width + 2, vim.o.columns - 4)
		local height = math.min(#def_lines, vim.o.lines - 4)

		local fbuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(fbuf, 0, -1, false, def_lines)
		vim.bo[fbuf].filetype = "go"

		local fwin = vim.api.nvim_open_win(fbuf, false, {
			relative = "cursor",
			row = 1,
			col = 0,
			width = width,
			height = height,
			border = "rounded",
			style = "minimal",
		})

		vim.keymap.set("n", "q", function()
			if vim.api.nvim_win_is_valid(fwin) then
				vim.api.nvim_win_close(fwin, true)
			end
		end, { buffer = fbuf, noremap = true })

		vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave" }, {
			once = true,
			callback = function()
				if vim.api.nvim_win_is_valid(fwin) then
					vim.api.nvim_win_close(fwin, true)
				end
			end,
		})
	end)
end, { desc = "Peek type definition" })
vim.keymap.set("n", "<C-]>", "<cmd>lua vim.lsp.buf.definition()<CR>", { silent = true })
vim.keymap.set("n", "<leader>do", "<cmd>lua vim.diagnostic.open_float()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "[e", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>")
vim.keymap.set("n", "]e", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>")
vim.keymap.set("n", "<leader>oi", function()
	vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
end, { desc = "Organize imports" })

-- Buffers
vim.keymap.set("n", "<Tab>", ":bn<CR>")
vim.keymap.set("n", "<S-Tab>", ":bp<CR>")
vim.keymap.set("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Windows
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

-- Editing
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "p", '"_dP')
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Clipboard
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')
vim.keymap.set("n", "<leader>cp", '<cmd>let @+ = expand("%:p")<CR>', { desc = "Copy file path" })

-- Search
vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR>")

-- Terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<leader>tt", ":term<CR>", { desc = "Open terminal" })
vim.keymap.set("n", "<leader>st", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.cmd.startinsert()
	vim.api.nvim_win_set_height(0, 10)
end)
vim.keymap.set("n", "<leader>vt", function()
	local new_width = math.floor(vim.o.columns / 3)
	vim.cmd.new()
	vim.cmd.term()
	vim.cmd.wincmd("L")
	vim.cmd.startinsert()
	vim.api.nvim_win_set_width(0, new_width)
end)

-- Quickfix
vim.keymap.set("n", "<leader>h", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
vim.keymap.set("n", "<leader>;", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })

-- Formatter
vim.keymap.set("n", "F", ":Format<CR>")

-- Source
vim.keymap.set("n", "<leader>so", "<cmd>source %<CR>")

-- Neogit
vim.keymap.set("n", "<leader>ne", ":Neogit<CR>", { desc = "Neogit" })

-- FzfLua
vim.keymap.set("n", "<leader><space>", ":FzfLua files<CR>", { desc = "Files" })
vim.keymap.set("n", "<leader><Tab>", ":FzfLua buffers<CR>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fu", ":FzfLua grep_cword<CR>", { desc = "Grep word" })
vim.keymap.set("n", "<leader>fw", ":FzfLua grep<CR>", { desc = "Grep" })
vim.keymap.set("n", "<leader>fm", ":FzfLua marks<CR>", { desc = "Marks" })
vim.keymap.set("n", "<leader>td", ":FzfLua diagnostics_workspace<CR>", { desc = "Diagnostics" })
vim.keymap.set("n", "R", ":FzfLua lsp_references<CR>", { desc = "LSP references" })

-- DAP (odkomentuj pro aktivaci debuggeru)
-- require("dap")

-- AsyncRun / Go linters
vim.keymap.set("n", "<leader>la", ":copen<CR>:AsyncRun make lintall<CR>", { desc = "make lintall" })
vim.keymap.set("n", "<leader>lr", ":copen<CR>:AsyncRun revive ./...<CR>", { desc = "revive" })
vim.keymap.set("n", "<leader>ll", ":copen<CR>:AsyncRun golangci-lint run ./...<CR>", { desc = "golangci-lint" })
vim.keymap.set("n", "<leader>lc", ":copen<CR>:AsyncRun go tool gocritic check ./...<CR>", { desc = "gocritic" })
