return {
	"tripplyons/stacker.nvim",
	event = "BufEnter",
	config = function()
		local stacker = require("stacker")
		local opts = {}
		stacker.setup(opts)

		-- <leader>1 will navigate to the most recently used buffer, <leader>2 for 2nd most recently used buffer, etc.
		for i = 1, 9 do
			vim.keymap.set("n", "<leader>" .. i, function()
				stacker.navigate(i)
			end)
		end

		-- <leader>0 will navigate to the 10th most recently used buffer
		vim.keymap.set("n", "<leader>0", function()
			stacker.navigate(10)
		end)

		-- <leader>dh will delete the buffer history for the current directory
		vim.keymap.set("n", "<leader>dh", function()
			stacker.clear_history()
		end)

		local inactive_color = "#808080"
		local active_color = "#ffffff"
		local number_color = "orange"
		vim.cmd("highlight! StackerInactive guibg=black guifg=" .. inactive_color)
		vim.cmd("highlight! StackerActive guibg=black guifg=" .. active_color)
		vim.cmd("highlight! StackerNumber guibg=black guifg=" .. number_color)
		vim.api.nvim_set_hl(0, "TabLineFill", { bg = "black", fg = "#808080" })
	end,
}
