return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("fzf-lua").setup({
			-- fzf_bin = "sk",
			fzf_colors = true,
			files = {
				cmd = "fd --type f --hidden --no-ignore --exclude .git",
			},
			fzf_opts = {
				["--color"] = "fg:#c0c0c0,bg:#1e1e2e,fg+:#ffa500,bg+:#2e2e2e,hl:#61afef,hl+:#ffcc00",
			},
			file_icon_padding = " ",
			previewers = {
				builtin = {
					syntax_limit_b = -102400, -- 100KB limit on highlighting files
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
	end,
}
