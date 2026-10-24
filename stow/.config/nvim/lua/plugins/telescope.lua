return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		opts = {},
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Search project text" },
			{ "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Search word under cursor" },
			{ "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
			{ "<leader>fo", "<cmd>Telescope oldfiles<CR>", desc = "Find recent files" },
			{ "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Find help" },
			{ "<leader>fr", "<cmd>Telescope resume<CR>", desc = "Resume last search" },
		},
	},
}
