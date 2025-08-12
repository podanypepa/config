-- lsp servers configs
-- https://github.com/neovim/nvim-lspconfig/tree/master/lsp

vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("jsonls")
vim.lsp.enable("yamlls")
vim.lsp.enable("dockerls")
vim.lsp.enable("svelte")
vim.lsp.enable("bashls")
vim.lsp.enable("docker_compose_language_service")
vim.lsp.enable("html")
vim.lsp.enable("pylsp")
vim.lsp.enable("systemd_ls")
vim.lsp.enable("templ")
vim.lsp.enable("ts_ls")
-- vim.lsp.enable("pyright")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
			-- vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
			vim.keymap.set("i", "<C-Space>", function()
				vim.lsp.completion.get()
			end)
		end
	end,
})

vim.diagnostic.config({
	-- virtual_text = true,
	virtual_lines = true,
	signs = true,
	update_in_insert = true,
	-- float = true,
	float = {
		header = false,
		border = "single",
		focusable = true,
		source = true, -- Or "if_many"
		prefix = "",
	},
	underline = false,
	severity_sort = true,
})
