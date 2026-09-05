return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add          = { text = "┃" },
      change       = { text = "┃" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
      untracked    = { text = "┆" },
    },

    signs_staged = {
      add          = { text = "┃" },
      change       = { text = "┃" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
      untracked    = { text = "┆" },
    },

    signcolumn = true,
    numhl = false,
    linehl = false,
    word_diff = false,

    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },

    attach_to_untracked = true,

    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 300,
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "<author>, <author_time:%m-%d-%Y>",

    preview_config = {
      border = "single",
      style = "minimal",
      relative = "cursor",
    },

    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      -- Navigation
      map("n", "]c", gs.next_hunk)
      map("n", "[c", gs.prev_hunk)

      -- Actions
      map("n", "<leader>hs", gs.stage_hunk)
      map("n", "<leader>hr", gs.reset_hunk)
      map("n", "<leader>hS", gs.stage_buffer)
      map("n", "<leader>hu", gs.undo_stage_hunk)
      map("n", "<leader>hp", gs.preview_hunk)

      -- Blame
      map("n", "<leader>hb", function()
        gs.blame_line { full = true }
      end)

      map("n", "<leader>hd", gs.diffthis)
    end,
  },
}
