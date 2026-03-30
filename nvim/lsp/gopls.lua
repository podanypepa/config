return {
	cmd = { "gopls" },
	filetypes = { "go" },
	settings = {
		gopls = {
			completeUnimported = true,
			completionDocumentation = true,
			hoverKind = "FullDocumentation",
			usePlaceholders = false,
			buildFlags = { "-tags=prod,local,dev,stage" },
			directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
			analyses = {
				unreachable = true,
				unusedparams = true,
				unusedwrite = true,
			},
			codelenses = {
				generate = true,
				tidy = true,
				upgrade_dependency = true,
				vendor = true,
			},
			staticcheck = true,

			-- new config
			-- gofumpt = true,
			-- semanticTokens = true,
		},
	},
	autostart = true,
}
