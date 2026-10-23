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
vim.opt.splitright = true
vim.opt.showmode = false
vim.opt.cmdheight = 1
vim.opt.updatetime = 200
vim.opt.confirm = true
vim.opt.autoread = true
vim.opt.autowrite = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.winborder = "rounded"

vim.opt.guicursor = {
	"n-v-c:block",
	"i:block-blinkon100-blinkoff100-blinkwait50",
	"r:hor20",
}

vim.api.nvim_set_hl(0, "Comment", { italic = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({ higroup = "YankHighlight", timeout = 400 })
	end,
})

-- 'autoread' sam nic nehlida; zmeny zvenku (Claude Code, git) nacti pri navratu
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermLeave" }, {
	callback = function()
		if vim.fn.getcmdwintype() == "" then
			vim.cmd.checktime()
		end
	end,
})

-- tmux: pane s nvim ma @pane-is-vim, tmux podle nej posle C-h/j/k/l sem
if vim.env.TMUX then
	local function tmux_flag(on)
		local pane = vim.env.TMUX_PANE
		vim.system(on and { "tmux", "set", "-p", "-t", pane, "@pane-is-vim", "1" } or { "tmux", "set", "-pu", "-t", pane, "@pane-is-vim" })
	end
	vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, { callback = function() tmux_flag(true) end })
	vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, { callback = function() tmux_flag(false) end })
end

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
	gh("onsails/lspkind.nvim"),
	gh("skywind3000/asyncrun.vim"),
	gh("zbirenbaum/copilot.lua"),
	gh("mhartington/formatter.nvim"),
	gh("windwp/nvim-autopairs"),
	gh("lewis6991/gitsigns.nvim"),
	gh("mfussenegger/nvim-dap"),
	gh("nvim-neotest/nvim-nio"),
	gh("rcarriga/nvim-dap-ui"),
	gh("leoluz/nvim-dap-go"),
	gh("mfussenegger/nvim-dap-python"),
	gh("b0o/SchemaStore.nvim"),
	gh("theHamsta/nvim-dap-virtual-text"),
	gh("neovim/nvim-lspconfig"),
	gh("mason-org/mason.nvim"),
	gh("mason-org/mason-lspconfig.nvim"),
})

-- Tyhle se pri startu ani nepridavaji do 'runtimepath'. Jejich plugin/ a
-- after/plugin/ soubory by jinak natahly cely nvim-cmp a LuaSnip (~30 ms).
-- Nahazuji se pres :packadd az v lazy bloku nize.
local completion_plugins = {
	"nvim-cmp",
	"cmp-nvim-lsp",
	"cmp-buffer",
	"cmp-path",
	"copilot-cmp",
	"LuaSnip",
}

vim.pack.add({
	gh("hrsh7th/nvim-cmp"),
	gh("hrsh7th/cmp-nvim-lsp"),
	gh("hrsh7th/cmp-buffer"),
	gh("hrsh7th/cmp-path"),
	gh("L3MON4D3/LuaSnip"),
	gh("zbirenbaum/copilot-cmp"),
}, { load = function() end })

-- ── lazy loading ──────────────────────────────────────────────────────────
-- Fronta setupu, ktere nemusi bezet pred prvnim vykreslenim obrazovky.
-- Kazdy krok jede v samostatnem timeru, takze UI mezi nimi dycha.
local lazy_queue = {}
local function lazy(fn)
	lazy_queue[#lazy_queue + 1] = fn
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		local i = 0
		local function step()
			i = i + 1
			local fn = lazy_queue[i]
			if not fn then
				return
			end
			local ok, err = pcall(fn)
			if not ok then
				vim.notify("lazy setup #" .. i .. ": " .. tostring(err), vim.log.levels.ERROR)
			end
			vim.defer_fn(step, 1)
		end
		vim.defer_fn(step, 1)
	end,
})

-- Setup, ktery se ma spustit pri prvnim pouziti (a nejpozdeji z lazy fronty).
local function on_demand(fn)
	local done = false
	local function ensure()
		if done then
			return
		end
		done = true
		fn()
	end
	lazy(ensure)
	return ensure
end

-- ── mason ─────────────────────────────────────────────────────────────────
-- Z mason.setup() je pri startu potreba jedina vec: mason/bin v PATH.
-- Registry, :Mason a ensure_installed az po startu.
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

-- `nvim` spusteny v projektu s .venv: aktivuj ho (term, ruff, pytest, debugpy).
-- Az za mason/bin, aby mel prednost ruff ve verzi, kterou ma projekt.
do
	local venv = vim.fn.getcwd() .. "/.venv"
	if not vim.env.VIRTUAL_ENV and vim.uv.fs_stat(venv .. "/bin/python") then
		vim.env.VIRTUAL_ENV = venv
		vim.env.PATH = venv .. "/bin:" .. vim.env.PATH
	end
end

lazy(function()
	require("mason").setup()
	require("mason-lspconfig").setup({
		ensure_installed = { "gopls", "pyright", "ruff", "jsonls", "yamlls", "vtsls", "eslint", "biome", "lua_ls" },
	})
	-- ne-LSP nastroje (mason-lspconfig je neresi)
	local registry = require("mason-registry")
	registry.refresh(function()
		for _, name in ipairs({ "debugpy" }) do
			local ok, pkg = pcall(registry.get_package, name)
			if ok and not pkg:is_installed() then
				pkg:install()
			end
		end
	end)
end)

-- parsers (Go, Python, TOML, YAML, JSON, JS/TS) - runtimepath i parsery se registruji az pri prvnim pouziti
local ts_langs = {
	go = "go",
	gomod = "gomod",
	gowork = "gowork",
	gosum = "gosum",
	python = "python",
	toml = "toml",
	yaml = "yaml",
	json = "json",
	javascript = "javascript",
	javascriptreact = "javascript",
	typescript = "typescript",
	typescriptreact = "tsx",
}

local ts_ready = false
local function ts_setup()
	if ts_ready then
		return
	end
	ts_ready = true
	local data = vim.fn.stdpath("data")
	vim.opt.runtimepath:append(data .. "/treesitter")
	-- query files (highlights.scm atd.) jsou v nvim-treesitter
	vim.cmd.packadd("nvim-treesitter")
	local parser_dir = data .. "/treesitter/parser/"
	local seen = {}
	for _, lang in pairs(ts_langs) do
		if not seen[lang] then
			seen[lang] = true
			vim.treesitter.language.add(lang, { path = parser_dir .. lang .. ".so" })
		end
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(ts_langs),
	callback = function(ev)
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
		if ok and stats and stats.size > 100 * 1024 then
			return
		end
		ts_setup()
		vim.treesitter.start(ev.buf, ts_langs[vim.bo[ev.buf].filetype])
	end,
})

local oil_setup = on_demand(function()
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
end)

-- `nvim .` / `nvim <dir>` potrebuje oil hned (hijack netrw)
local first_arg = vim.fn.argv(0)
if type(first_arg) == "string" and first_arg ~= "" and vim.fn.isdirectory(first_arg) == 1 then
	oil_setup()
end

vim.keymap.set("n", "-", function()
	oil_setup()
	vim.cmd("Oil")
end, { desc = "Open parent directory" })

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
vim.api.nvim_set_hl(0, "StlModeNormal", { fg = "#888c90", bold = true })
vim.api.nvim_set_hl(0, "StlModeInsert", { fg = "#ffffff", bg = "#8b0000", bold = true })
vim.api.nvim_set_hl(0, "StlModeVisual", { fg = "#000000", bg = "#e0a050", bold = true })
vim.api.nvim_set_hl(0, "StlModeReplace", { fg = "#ffffff", bg = "#a03080", bold = true })
vim.api.nvim_set_hl(0, "StlModeCommand", { fg = "#000000", bg = "#6090d0", bold = true })

-- mod podle prvniho znaku nvim_get_mode().mode (showmode je vypnuty)
local stl_modes = {
	n = { "NORMAL", "StlModeNormal" },
	i = { "INSERT", "StlModeInsert" },
	v = { "VISUAL", "StlModeVisual" },
	V = { "V-LINE", "StlModeVisual" },
	["\22"] = { "V-BLOCK", "StlModeVisual" },
	s = { "SELECT", "StlModeVisual" },
	S = { "S-LINE", "StlModeVisual" },
	["\19"] = { "S-BLOCK", "StlModeVisual" },
	R = { "REPLACE", "StlModeReplace" },
	c = { "COMMAND", "StlModeCommand" },
	t = { "TERMINAL", "StlModeInsert" },
}
function _G.stl_mode()
	local m = stl_modes[vim.api.nvim_get_mode().mode:sub(1, 1)] or { "NORMAL", "StlModeNormal" }
	return "%#" .. m[2] .. "# " .. m[1] .. " %*"
end
vim.opt.statusline = "%{%v:lua.stl_mode()%}%#MojeBarvaSouboru# %f %*"
vim.api.nvim_create_autocmd("ModeChanged", { command = "redrawstatus" })
vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "NONE" })
vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "NONE" })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "NONE" })

-- LSP setup az po prvnim vykresleni: require("vim.lsp") + resolve lsp/*.lua
-- u kazdeho enable() je ~5 ms. enable() po VimEnter se sam pripoji
-- i k bufferum otevrenym z prikazove radky.
lazy(function()
	-- Copilot sype AbortError na stderr, ktery vim.lsp loguje jako ERROR.
	-- Log bez tohohle roste na desitky MB. Pro ladeni prepni na "WARN".
	vim.lsp.log.set_level(vim.log.levels.OFF)

	-- nvim-lspconfig je v rtp az za ~/.config/nvim, takze jeho lsp/gopls.lua
	-- prebije nase filetypes. vim.lsp.config() ma vyssi prioritu nez lsp/*.lua.
	vim.lsp.config("gopls", { filetypes = { "go", "gomod", "gowork" } })
	vim.lsp.enable("gopls")
	-- Pyright = typy, ruff = lint/format/importy. Venv se hleda v koreni projektu.
	vim.lsp.config("pyright", {
		settings = {
			pyright = { disableOrganizeImports = true },
			python = {
				analysis = {
					typeCheckingMode = "basic",
					autoImportCompletions = true,
					diagnosticMode = "openFilesOnly",
				},
			},
		},
		before_init = function(_, config)
			config.settings.python.pythonPath = require("py").python(config.root_dir)
		end,
	})
	vim.lsp.config("ruff", {
		init_options = {
			settings = {
				-- plati jen kdyz projekt nema vlastni [tool.ruff]
				lint = { extendSelect = { "I", "B", "UP" } },
			},
		},
	})
	vim.lsp.enable("pyright")
	vim.lsp.enable("ruff")

	-- JSON: validace podle SchemaStore (package.json, tsconfig, compose...).
	-- Katalog je velka tabulka, nacita se az pri startu serveru.
	vim.lsp.config("jsonls", {
		settings = { json = { validate = { enable = true } } },
		before_init = function(_, config)
			config.settings.json.schemas = require("schemastore").json.schemas()
		end,
	})
	vim.lsp.enable("jsonls")

	-- YAML: stejne schemata (GitHub Actions, compose, k8s...). Vestaveny
	-- schemaStore yamlls vypnuty, jinak by katalog stahoval znovu sam.
	vim.lsp.config("yamlls", {
		settings = {
			yaml = {
				validate = true,
				schemaStore = { enable = false, url = "" },
			},
		},
		before_init = function(_, config)
			config.settings.yaml.schemas = require("schemastore").yaml.schemas()
		end,
	})
	vim.lsp.enable("yamlls")

	-- JS/TS: vtsls = typy/doplnovani, eslint + biome jen v projektech s jejich configem
	vim.lsp.config("vtsls", {
		settings = {
			vtsls = { autoUseWorkspaceTsdk = true },
			typescript = { updateImportsOnFileMove = { enabled = "always" } },
			javascript = { updateImportsOnFileMove = { enabled = "always" } },
		},
	})
	vim.lsp.enable("vtsls")
	vim.lsp.enable("eslint")
	vim.lsp.enable("biome")
	vim.lsp.enable("lua_ls")
end)

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client.name == "ruff" then
			-- hover dela pyright
			client.server_capabilities.hoverProvider = false
		end
		if client.name == "eslint" then
			-- eslint --fix pred ulozenim, formatter (prettier/biome) jede po nem
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = ev.buf,
				callback = function()
					if vim.fn.exists(":LspEslintFixAll") == 2 then
						vim.cmd("LspEslintFixAll")
					end
				end,
			})
		end
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
	update_in_insert = false,
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

lazy(function()
	require("nvim-autopairs").setup()
end)

lazy(function()
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
end)

local fzf_setup = on_demand(function()
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
end)

lazy(function()
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
end)


-- cmp + copilot: dohromady ~120-200 ms, nic z toho neni potreba
-- pred prvnim vykreslenim. Poradi: cmp -> copilot -> copilot_cmp.
lazy(function()
	-- :packadd sourcuje jen plugin/, ne after/plugin/ - a prave tam si
	-- cmp-nvim-lsp/buffer/path registruji svoje zdroje.
	local pack_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/"
	for _, name in ipairs(completion_plugins) do
		vim.cmd.packadd(name)
		for _, f in ipairs(vim.fn.glob(pack_dir .. name .. "/after/plugin/**/*.{vim,lua}", false, true)) do
			vim.cmd.source(f)
		end
	end

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
	require("copilot").setup({
		suggestion = { enabled = false },
		panel = { enabled = false },
	})
	require("copilot_cmp").setup()
end)

lazy(function()
	local util = require("formatter.util")
	-- Biome kdyz ho projekt pouziva, jinak prettier. Oba se berou
	-- z node_modules projektu, kdyz tam jsou (sedi verze s CI).
	local biome_files = { "biome.json", "biome.jsonc" }
	local function js_formatter()
		if vim.fs.root(0, biome_files) then
			local cfg = require("formatter.filetypes.javascript").biome()
			cfg.try_node_modules = true
			return cfg
		end
		return require("formatter.filetypes.javascript").prettier()
	end
	require("formatter").setup({
		logging = true,
		log_level = vim.log.levels.WARN,
		filetype = {
			rust = {
				require("formatter.filetypes.rust").rustfmt,
			},
			json = {
				function()
					return {
						exe = "jq",
						args = { "--indent", "4", "." },
						stdin = true,
					}
				end,
			},
			javascript = { js_formatter },
			javascriptreact = { js_formatter },
			typescript = { js_formatter },
			typescriptreact = { js_formatter },
			svelte = {
				require("formatter.filetypes.javascript").prettier,
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
		},
	})
end)

-- Trailing whitespace pred zapisem (driv "*" ve formatteru = druhy zapis kazdeho souboru)
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		local view = vim.fn.winsaveview()
		vim.cmd([[keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})

-- FormatWrite jen pro filetypy, ktere formatter opravdu ma (Go resi gopls nize)
vim.api.nvim_create_augroup("__formatter__", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = "__formatter__",
	callback = function(ev)
		if require("formatter.config").values.filetype[vim.bo[ev.buf].filetype] then
			vim.cmd("FormatWrite")
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function(ev)
		require("py").attach(ev.buf)
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	-- organize imports + gofumpt (gopls) pred zapisem, bez externiho procesu
	callback = function(ev)
		local client = vim.lsp.get_clients({ bufnr = 0 })[1]
		local enc = client and client.offset_encoding or "utf-16"
		local params = vim.lsp.util.make_range_params(0, enc)
		params.context = { only = { "source.organizeImports" }, diagnostics = {} }
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
		for cid, res in pairs(result or {}) do
			local c = vim.lsp.get_client_by_id(cid)
			for _, r in pairs(res.result or {}) do
				if r.edit then
					vim.lsp.util.apply_workspace_edit(r.edit, c and c.offset_encoding or "utf-16")
				end
				if c and r.command then
					c:exec_cmd(type(r.command) == "table" and r.command or r, { bufnr = ev.buf })
				end
			end
		end
		vim.lsp.buf.format({
			bufnr = ev.buf,
			timeout_ms = 3000,
			filter = function(cl)
				return cl.name == "gopls"
			end,
		})
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
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "<leader>oi", function()
	vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
end, { desc = "Organize imports" })

-- Buffers
vim.keymap.set("n", "<Tab>", ":bn<CR>")
vim.keymap.set("n", "<S-Tab>", ":bp<CR>")
vim.keymap.set("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Windows
local function navigate(dir, tmux_dir)
	-- na okraji pokracuje do sousedniho tmux pane
	local win = vim.api.nvim_get_current_win()
	vim.cmd.wincmd(dir)
	if vim.env.TMUX and win == vim.api.nvim_get_current_win() then
		vim.system({ "tmux", "select-pane", "-" .. tmux_dir })
	end
end
vim.keymap.set("n", "<C-h>", function() navigate("h", "L") end)
vim.keymap.set("n", "<C-l>", function() navigate("l", "R") end)
vim.keymap.set("n", "<C-j>", function() navigate("j", "D") end)
vim.keymap.set("n", "<C-k>", function() navigate("k", "U") end)

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
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>D", '"_d', { desc = "Delete without clobbering registers" })
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
vim.keymap.set("n", "<leader><space>", function()
	fzf_setup()
	vim.cmd("FzfLua files")
end, { desc = "Files" })
vim.keymap.set("n", "<leader><Tab>", function()
	fzf_setup()
	vim.cmd("FzfLua buffers")
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fu", function()
	fzf_setup()
	vim.cmd("FzfLua grep_cword")
end, { desc = "Grep word" })
vim.keymap.set("n", "<leader>fw", function()
	fzf_setup()
	vim.cmd("FzfLua grep")
end, { desc = "Grep" })
vim.keymap.set("n", "<leader>fm", function()
	fzf_setup()
	vim.cmd("FzfLua marks")
end, { desc = "Marks" })
vim.keymap.set("n", "<leader>td", function()
	fzf_setup()
	vim.cmd("FzfLua diagnostics_workspace")
end, { desc = "Diagnostics" })
vim.keymap.set("n", "R", function()
	fzf_setup()
	vim.cmd("FzfLua lsp_references")
end, { desc = "LSP references" })

-- DAP - setup (lua/dapconf.lua) az pri prvnim pouziti
local function dap_do(fn)
	return function()
		require("dapconf")
		fn(require("dap"))
	end
end
vim.keymap.set("n", "<leader>db", dap_do(function(dap)
	dap.toggle_breakpoint()
end), { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", dap_do(function(dap)
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end), { desc = "Conditional breakpoint" })
vim.keymap.set("n", "<leader>dc", dap_do(function(dap)
	dap.continue()
end), { desc = "Continue / start" })
vim.keymap.set("n", "<leader>dC", dap_do(function(dap)
	dap.run_to_cursor()
end), { desc = "Run to cursor" })
vim.keymap.set("n", "<leader>dsi", dap_do(function(dap)
	dap.step_into()
end), { desc = "Step into" })
vim.keymap.set("n", "<leader>dso", dap_do(function(dap)
	dap.step_over()
end), { desc = "Step over" })
vim.keymap.set("n", "<leader>dsO", dap_do(function(dap)
	dap.step_out()
end), { desc = "Step out" })
vim.keymap.set("n", "<leader>de", dap_do(function()
	require("dapui").eval()
end), { desc = "Eval under cursor" })
vim.keymap.set("n", "<leader>du", dap_do(function()
	require("dapui").toggle()
end), { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<leader>dt", dap_do(function()
	if vim.bo.filetype == "python" then
		require("dap-python").test_method()
	else
		require("dap-go").debug_test()
	end
end), { desc = "Debug test" })
vim.keymap.set("n", "<leader>dT", dap_do(function()
	require("dap-python").test_class()
end), { desc = "Debug test class (python)" })
vim.keymap.set("n", "<leader>dq", dap_do(function(dap)
	dap.terminate()
	require("dapui").close()
end), { desc = "Terminate" })

-- AsyncRun / Go linters
vim.keymap.set("n", "<leader>la", ":copen<CR>:AsyncRun make lintall<CR>", { desc = "make lintall" })
vim.keymap.set("n", "<leader>lr", ":copen<CR>:AsyncRun revive ./...<CR>", { desc = "revive" })
vim.keymap.set("n", "<leader>ll", ":copen<CR>:AsyncRun golangci-lint run ./...<CR>", { desc = "golangci-lint" })
vim.keymap.set("n", "<leader>lc", ":copen<CR>:AsyncRun gocritic check ./...<CR>", { desc = "gocritic" })
