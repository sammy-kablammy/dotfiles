local builtin = require("telescope.builtin")
local utils = require("telescope.utils")

-- make sure you have ripgrep installed

-- you can use 'builtin.builtin' to find builtin pickers
-- or do :Telescope and scroll around

local function map(lhs, rhs, desc)
    if desc then
        vim.keymap.set("n", "<leader>f" .. lhs, rhs, { desc = desc })
    else
        vim.keymap.set("n", "<leader>f" .. lhs, rhs, {})
    end
end

map("f", function()
    builtin.find_files({ hidden = true })
end, "find files")
map("F", function()
    builtin.find_files({ hidden = true, cwd = utils.buffer_dir() })
end, "find files relative to current buffer")
map("h", builtin.help_tags, "help")
map("b", builtin.buffers, "buffers")
map("g", builtin.live_grep, "live grep")
map("o", builtin.oldfiles, "old files")
map("q", builtin.quickfix, "quickfix list")
map("l", builtin.loclist, "local list")
map("m", builtin.diagnostics, "diagnostics")
map("c", builtin.command_history, "command history")
map("p", builtin.planets, "planets") -- lol
map("k", builtin.keymaps, "keymaps")

local function find_notes()
    builtin.live_grep({
        cwd = "~/notes/main",
        glob_pattern = "*.md",
    })
end
vim.api.nvim_create_user_command("FindNotes", find_notes, {})
map("n", find_notes, "notes")

-- could i be using grep_string here? meh. this way keeps the #, which i like
vim.keymap.set('n', '<leader>mt',
    '"tyy<cmd>lua require("telescope.builtin").live_grep()<cr><c-r>t',
    { desc = "markdown: telescope by tag" }
)
