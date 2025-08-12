return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {},
	-- Optional dependencies
	-- dependencies = { { "echasnovski/mini.icons", opts = {} } },
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
	config = function()
		require("oil").setup({
			keymaps = {},
			confirm = false,
			skip_confirm_for_simple_edits = true,
			prompt_save_on_select_new_entry = false,
			default_file_explorer = true,
			float = {
				preview_split = "left",
			},
			columns = {
				"icon",
				-- "permissions",
				-- "size",
				-- "mtime",
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
					-- sort order can be "asc" or "desc"
					-- see :help oil-columns to see which columns are sortable
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
	end,
}
