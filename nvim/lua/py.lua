-- Python: venv, ruff on save, pytest -> quickfix, spusteni souboru.
-- Nacita se az pri prvnim python bufferu (FileType v init.lua).
local M = {}

local root_markers = { "pyproject.toml", "uv.lock", "setup.py", "setup.cfg", "requirements.txt", ".venv", ".git" }

function M.root(buf)
	return vim.fs.root(buf or 0, root_markers) or vim.fn.getcwd()
end

-- .venv projektu ma prednost pred VIRTUAL_ENV (to muze byt z jineho projektu)
function M.venv(root)
	for _, name in ipairs({ ".venv", "venv", "env" }) do
		local p = root .. "/" .. name
		if vim.uv.fs_stat(p .. "/bin/python") then
			return p
		end
	end
	return vim.env.VIRTUAL_ENV
end

function M.python(root)
	local venv = M.venv(root or M.root())
	if venv then
		return venv .. "/bin/python"
	end
	return vim.fn.exepath("python3")
end

-- ── ruff: serad importy + naformatuj ─────────────────────────────────────
local function code_action_sync(buf, client, kind)
	local params = {
		textDocument = { uri = vim.uri_from_bufnr(buf) },
		range = {
			start = { line = 0, character = 0 },
			["end"] = { line = vim.api.nvim_buf_line_count(buf), character = 0 },
		},
		context = { only = { kind }, diagnostics = {} },
	}
	local res = client:request_sync("textDocument/codeAction", params, 2000, buf)
	for _, action in ipairs(res and res.result or {}) do
		if not action.edit and action.data then
			local resolved = client:request_sync("codeAction/resolve", action, 2000, buf)
			action = resolved and resolved.result or action
		end
		if action.edit then
			vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
		end
	end
end

function M.format(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	local client = vim.lsp.get_clients({ bufnr = buf, name = "ruff" })[1]
	if not client then
		return
	end
	code_action_sync(buf, client, "source.organizeImports.ruff")
	vim.lsp.buf.format({ bufnr = buf, name = "ruff", timeout_ms = 2000 })
end

-- ── pytest ────────────────────────────────────────────────────────────────
-- Nejblizsi test pod kurzorem jako pytest node id: soubor::Trida::test_fn
local function nearest_test(buf)
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf })
	if not ok then
		return nil
	end
	local parts, func = {}, nil
	while node do
		local t = node:type()
		if t == "function_definition" or t == "class_definition" then
			local name = vim.treesitter.get_node_text(node:field("name")[1], buf)
			if t == "class_definition" then
				table.insert(parts, 1, name)
			elseif name:match("^test") then
				func = name
			end
		end
		node = node:parent()
	end
	if func then
		parts[#parts + 1] = func
	end
	return #parts > 0 and table.concat(parts, "::") or nil
end

local last_run

local function pytest(args, root)
	root = root or M.root()
	local cmd = vim.list_extend({ M.python(root), "-m", "pytest", "-q", "--tb=short", "--color=no" }, args)
	last_run = { args = args, root = root }
	vim.notify("pytest " .. table.concat(args, " "), vim.log.levels.INFO)
	vim.system(cmd, { cwd = root, text = true }, function(out)
		vim.schedule(function()
			local lines = vim.split((out.stdout or "") .. (out.stderr or ""), "\n", { trimempty = true })
			-- pytest tiskne cesty relativne ke korenu, quickfix je resolvuje vuci cwd nvimu
			for i, l in ipairs(lines) do
				if l:match("^[^%s/][^%s:]*%.py:%d+:") then
					lines[i] = root .. "/" .. l
				end
			end
			vim.fn.setqflist({}, " ", { title = "pytest", lines = lines, efm = "%f:%l: %m" })
			if out.code == 0 then
				vim.cmd.cclose()
				vim.notify("pytest: " .. (lines[#lines] or "ok"), vim.log.levels.INFO)
			elseif out.code == 5 then
				vim.notify("pytest: zadne testy", vim.log.levels.WARN)
			else
				vim.cmd("botright copen")
				vim.notify("pytest: " .. (lines[#lines] or "selhalo"), vim.log.levels.ERROR)
			end
		end)
	end)
end

function M.test_nearest()
	local buf = vim.api.nvim_get_current_buf()
	local root = M.root(buf)
	local file = vim.fs.relpath(root, vim.api.nvim_buf_get_name(buf)) or vim.api.nvim_buf_get_name(buf)
	local id = nearest_test(buf)
	pytest({ id and (file .. "::" .. id) or file }, root)
end

function M.test_file()
	local buf = vim.api.nvim_get_current_buf()
	local root = M.root(buf)
	pytest({ vim.fs.relpath(root, vim.api.nvim_buf_get_name(buf)) or vim.api.nvim_buf_get_name(buf) }, root)
end

function M.test_all()
	pytest({})
end

function M.test_last()
	if not last_run then
		return vim.notify("pytest: zatim nic nebezelo", vim.log.levels.WARN)
	end
	pytest(last_run.args, last_run.root)
end

-- Spusteni souboru v terminalu dole (funguje input(), barvy, Ctrl-C)
function M.run_file()
	vim.cmd.write()
	local root = M.root()
	local file = vim.api.nvim_buf_get_name(0)
	vim.cmd("botright 12new")
	vim.fn.jobstart({ M.python(root), file }, { term = true, cwd = root })
	vim.cmd.startinsert()
end

-- ── buffer setup ──────────────────────────────────────────────────────────
function M.attach(buf)
	vim.opt_local.colorcolumn = "89"

	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
	end
	map("F", function()
		M.format(buf)
	end, "Ruff format + imports")
	map("<leader>pr", M.run_file, "Run file")
	map("<leader>pn", M.test_nearest, "pytest nearest")
	map("<leader>pf", M.test_file, "pytest file")
	map("<leader>pa", M.test_all, "pytest all")
	map("<leader>pl", M.test_last, "pytest last")
	map("<leader>pv", function()
		vim.notify("python: " .. M.python(M.root(buf)))
	end, "Show python interpreter")

	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = buf,
		callback = function()
			M.format(buf)
		end,
	})
end

return M
