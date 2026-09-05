return {
	{
		"stevearc/conform.nvim",
		opts = {
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},

			formatters_by_ft = {
				-- Go
				go = { "goimports", "gofumpt" },

				-- Web / JS ecosystem (all via prettierd)
				javascript = { "prettierd" },
				javascriptreact = { "prettierd" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				html = { "prettierd" },
				css = { "prettierd" },
				scss = { "prettierd" },
				json = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },

				-- Lua (for your nvim config)
				lua = { "stylua" },

				-- Shell
				sh = { "shfmt" },
				bash = { "shfmt" },

				-- Python
				python = { "black" },
			},
		},
	},
}
