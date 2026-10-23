-- Nacita se az pri prvnim <leader>d* (viz init.lua).
local dap = require("dap")
local dapui = require("dapui")

dapui.setup({
	icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
	controls = {
		icons = {
			pause = "⏸",
			play = "",
			step_into = "⏎",
			step_over = "⏭",
			step_out = "⏮",
			step_back = "b",
			run_last = "▶▶",
			terminate = "⏹",
			disconnect = "⏏",
		},
	},
})

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

require("nvim-dap-virtual-text").setup({
	enable = true,
	all_frames = true,
	virt_lines = false,
	commented = false,
	highlight_changed_variables = true,
	highlight_new_as_changed = false,
	show_stop_reason = true,
	only_first_definition = false,
	all_references = true,
})

require("dap-go").setup({
	delve = {
		path = "dlv",
		initialize_timeout_sec = 20,
	},
	tests = { verbose = true },
})

-- debugpy bezi z mason venv, laděny program z .venv projektu
local debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
local dap_python = require("dap-python")
dap_python.setup(vim.uv.fs_stat(debugpy) and debugpy or "python3")
dap_python.test_runner = "pytest"
dap_python.resolve_python = function()
	return require("py").python()
end

vim.list_extend(dap.configurations.python, {
	{
		type = "python",
		request = "launch",
		name = "Django runserver",
		program = "${workspaceFolder}/manage.py",
		args = { "runserver", "--noreload" },
		django = true,
		jinja = true,
		justMyCode = true,
	},
	{
		type = "python",
		request = "launch",
		name = "FastAPI (uvicorn)",
		module = "uvicorn",
		args = function()
			return { vim.fn.input("App (modul:app): ", "main:app"), "--port", "8000" }
		end,
		justMyCode = true,
	},
	{
		type = "python",
		request = "launch",
		name = "pytest (cely projekt)",
		module = "pytest",
		args = { "-q" },
		justMyCode = false,
	},
})

vim.api.nvim_set_hl(0, "MyBreakpointSign", { fg = "#FF0000" })
vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "MyBreakpointSign", linehl = "", numhl = "" })
