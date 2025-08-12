return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"leoluz/nvim-dap-go",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
	},
	lazy = true,
	keys = {
		{
			"<leader>dq",
			function()
				require("dap").terminate()
				require("dapui").close()
				require("nvim-dap-virtual-text").toggle()
			end,
			desc = "Terminate",
			nowait = true,
			remap = false,
		},
		{
			"<leader>dsi",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: Step Into",
		},
		{
			"<leader>dso",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: Step Over",
		},
		{
			"<leader>dsO",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: Step Out",
		},
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Debug: Set Conditional Breakpoint",
		},
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle Breakpoint",
		},
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Continue",
		},
		{
			"<leader>dC",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Run to Cursor",
		},
		{
			"<leader>dT",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate",
		},
		{
			"<leader>dt",
			function()
				require("dap-go").debug_test()
			end,
			desc = "Debug test",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				icons = {
					pause = "⏸",
					play = "",
					tep_into = "⏎",
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
			tests = {
				verbose = true,
			},
		})
		-- vim.fn.sign_define("DapBreakpoint", {
		-- 	-- text = "🔴", -- nerdfonts icon here
		-- 	text = "B",
		-- 	texthl = "DapBreakpointSymbol",
		-- 	linehl = "DapBreakpoint",
		-- 	numhl = "DapBreakpoint",
		-- })
		-- vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#FF5555" })

		vim.api.nvim_set_hl(0, "MyBreakpointSign", { fg = "#FF0000" })
		vim.fn.sign_define("DapBreakpoint", {
			-- text = "●",
			text = "B",
			texthl = "MyBreakpointSign",
			linehl = "",
			numhl = "",
		})
	end,
}
