return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon"):setup()
		end,
		keys = {
			{
				"<leader>a",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Harpoon: add file",
			},
			{
				"<leader>m",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon: toggle menu",
			},
			{
				"[H",
				function()
					require("harpoon"):list():prev()
				end,
				desc = "Harpoon: previous file",
			},
			{
				"]H",
				function()
					require("harpoon"):list():next()
				end,
				desc = "Harpoon: next file",
			},
			-- Keep <leader>h available for the existing Gitsigns mappings.
			{
				"<leader>1",
				function()
					require("harpoon"):list():select(1)
				end,
				desc = "Harpoon: file 1",
			},
			{
				"<leader>2",
				function()
					require("harpoon"):list():select(2)
				end,
				desc = "Harpoon: file 2",
			},
			{
				"<leader>3",
				function()
					require("harpoon"):list():select(3)
				end,
				desc = "Harpoon: file 3",
			},
			{
				"<leader>4",
				function()
					require("harpoon"):list():select(4)
				end,
				desc = "Harpoon: file 4",
			},
		},
	},
}
