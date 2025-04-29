return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				--ruff_lsp = {},
				pyright = {
					enabled = false,
				},
				basedpyright = {
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "standard",
								autoSearchPaths = true,
								autoImportCompletions = true,
								diagnosticsMode = "openFilesOnly",
							},
						},
					},
				},
			},
		},
	},
}
