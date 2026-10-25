return {
	"esmuellert/codediff.nvim",
	cmd = "CodeDiff",
	opts = {
		diff = {
			layout = "inline",
		},
	},
	keys = {
		{ "<leader>gd", "<cmd>CodeDiff<CR>", desc = "Review repository changes (CodeDiff)" },
		{ "<leader>gf", "<cmd>CodeDiff file HEAD<CR>", desc = "Review current file (CodeDiff)" },
	},
}
