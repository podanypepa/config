return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons", -- optional, but recommended
		},
		lazy = false, -- neo-tree will lazily load itself
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				popup_border_style = "NC", -- or "" to use 'winborder' on Neovim v0.11+
				enable_git_status = true,
				enable_diagnostics = true,
				open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
				window = {
					position = "right",
					width = 40,
				},
				default_component_configs = {},
				sources = {
					"filesystem",
					"buffers",
					"git_status",
				},
			})
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "FocusGained" }, {
				callback = function()
					local ok, manager = pcall(require, "neo-tree.sources.manager")
					if ok then
						manager.refresh("git_status")
					end
				end,
			})
		end,
	},
	{
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
		},
		config = function()
			require("lsp-file-operations").setup()
		end,
	},
}
