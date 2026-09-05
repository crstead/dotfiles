return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons", -- optional, but recommended
		},
		keys = {
			{
				"<leader>e",
				"<cmd>Neotree toggle<CR>",
				desc = "Toggle Neo-tree",
			},
			{
				"<leader>E",
				"<cmd>Neotree reveal<CR>",
				desc = "Reveal current file in Neo-tree",
			},
		},
		lazy = false, -- neo-tree will lazily load itself
	},
}
