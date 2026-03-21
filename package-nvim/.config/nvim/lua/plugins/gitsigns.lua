-- https://github.com/lewis6991/gitsigns.nvim

local gitsigns = require("gitsigns")

-- should h or g be used for hunks?
-- h. because dih. even though g will no longer be used for comments.
-- in the meantime we can do both g and h though
-- using h also means we won't conflict with g] and accidentally follow tag.

vim.keymap.set("n", "[h", function()
    gitsigns.nav_hunk("prev", { target = 'all' })
end, { desc = "previous git Hunk (including staged hunks)" })
vim.keymap.set("n", "]h", function()
    gitsigns.nav_hunk("next", { target = 'all' })
end, { desc = "next git Hunk (including staged hunks)" })
vim.keymap.set("n", "[H", function()
    gitsigns.nav_hunk("prev")
end, { desc = "previous git Hunk" })
vim.keymap.set("n", "]H", function()
    gitsigns.nav_hunk("next")
end, { desc = "next git Hunk" })

-- will eventually delete this
vim.keymap.set("n", "[g", function()
    -- gitsigns.nav_hunk("prev", { target = 'all' })
    print("use 'h' for hunks instead")
end, { desc = "previous git Hunk (including staged hunks)" })
vim.keymap.set("n", "]g", function()
    -- gitsigns.nav_hunk("next", { target = 'all' })
    print("use 'h' for hunks instead")
end, { desc = "next git Hunk (including staged hunks)" })
vim.keymap.set("n", "[G", function()
    -- gitsigns.nav_hunk("prev")
    print("use 'h' for hunks instead")
end, { desc = "previous git Hunk" })
vim.keymap.set("n", "]G", function()
    -- gitsigns.nav_hunk("next")
    print("use 'h' for hunks instead")
end, { desc = "next git Hunk" })

vim.keymap.set("n", "<leader>gb", gitsigns.blame)
-- this allows for the fabled 'dih' maneuver to delete inside hunk:
vim.keymap.set("v", "ih", gitsigns.select_hunk, { desc = "inside hunk textobject" })
vim.keymap.set("o", "ih", gitsigns.select_hunk, { desc = "inside hunk textobject" })
-- "around hunk" doesn't really make sense so it's not defined here

gitsigns.setup {
    signs = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
    },
    signs_staged = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
    },
    signs_staged_enable = true,
    signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
        follow_files = true
    },
    auto_attach = true,
    attach_to_untracked = false,
    current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
    },
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000, -- Disable if file is longer than this (in lines)
    preview_config = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
    },
}
