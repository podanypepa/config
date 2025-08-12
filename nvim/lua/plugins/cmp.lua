return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"onsails/lspkind.nvim",
		"L3MON4D3/LuaSnip",
	},
	config = function()
		local cmp = require("cmp")
		local cmp_select_opts = { behavior = cmp.SelectBehavior.Select }
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		local lspkind = require("lspkind")

		cmp.setup({
			enabled = true,
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},

			-- experimental = {
			-- 	ghost_text = true,
			-- },
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
				{ name = "nvim_lsp" },
				{ name = "vsnip" },
				{ name = "path" },
				-- { name = "cmdline" },
			}, {
				{ name = "buffer" },
			}),
			formatting = {
				format = lspkind.cmp_format({
					maxwidth = 50,
					ellipsis_char = "...",
				}),
			},
			-- formatting = {
			-- 	fields = { "abbr", "menu", "kind" },
			-- 	format = function(entry, item)
			-- 		local short_name = {
			-- 			nvim_lsp = "LSP",
			-- 			nvim_lua = "nvim",
			-- 		}
			-- 		local menu_name = short_name[entry.source.name] or entry.source.name
			-- 		item.menu = string.format("[%s]", menu_name)
			-- 		return item
			-- 	end,
			-- },
		})
	end,
}
