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

vim.api.nvim_set_hl(0, "MyBreakpointSign", { fg = "#FF0000" })
vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "MyBreakpointSign", linehl = "", numhl = "" })

vim.keymap.set("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional breakpoint" })
vim.keymap.set("n", "<leader>dc", function()
	require("dap").continue()
end, { desc = "Continue" })
vim.keymap.set("n", "<leader>dC", function()
	require("dap").run_to_cursor()
end, { desc = "Run to cursor" })
vim.keymap.set("n", "<leader>dsi", function()
	require("dap").step_into()
end, { desc = "Step into" })
vim.keymap.set("n", "<leader>dso", function()
	require("dap").step_over()
end, { desc = "Step over" })
vim.keymap.set("n", "<leader>dsO", function()
	require("dap").step_out()
end, { desc = "Step out" })
vim.keymap.set("n", "<leader>dt", function()
	require("dap-go").debug_test()
end, { desc = "Debug test" })
vim.keymap.set("n", "<leader>dq", function()
	require("dap").terminate()
	require("dapui").close()
	require("nvim-dap-virtual-text").toggle()
end, { desc = "Terminate" })
