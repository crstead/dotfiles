return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "auto",
				icons_enabled = true,
				-- Removes the triangle/arrow dividers between blocks and sections
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { statusline = {}, winbar = {} },
			},
			sections = {
				lualine_a = {},
				lualine_b = { "branch" },
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { { "diagnostics", sources = { "nvim_diagnostic" } } },
				lualine_y = {},
				lualine_z = {
					function()
						return string.format("%d:%d/%d", vim.fn.line("."), vim.fn.charcol("."), vim.fn.line("$"))
					end,
				},
			},
		})
	end,
}
