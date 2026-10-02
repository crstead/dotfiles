return {
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "LspAttach",
		priority = 900,
		config = function()
			require("tiny-inline-diagnostic").setup({
				options = {},
			})
			vim.diagnostic.config({ virtual_text = false, update_in_insert = true }) -- Disable Neovim's default virtual text diagnostics
		end,
	},
}
