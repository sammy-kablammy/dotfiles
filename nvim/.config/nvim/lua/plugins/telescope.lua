-- https://github.com/nvim-telescope/telescope.nvim
-- https://github.com/debugloop/telescope-undo.nvim

-- make sure you have ripgrep installed

local telescope = require("telescope")
local builtin = require("telescope.builtin")
local utils = require("telescope.utils")

telescope.setup({
    defaults = {
        layout_config = {
            width = 0.99, -- (this is a percentage)
            height = 0.99,
            -- width = vim.o.columns, -- this breaks when window is resized
            -- height = vim.o.lines,
            preview_cutoff = 5,
        },
        mappings = {
            n = {
                ["X"] = require("telescope.actions").delete_buffer,
            },
        },
    },
})

local function telescope_map(lhs, rhs, desc)
    vim.keymap.set("n", "<leader>f" .. lhs, rhs, { desc = desc })
end

-- telescope_map("f", function() builtin.find_files({ hidden = true }) end, "find files")
telescope_map("f", function() builtin.find_files() end, "find files")
telescope_map("F", function() builtin.find_files({ hidden = true, cwd = utils.buffer_dir() }) end, "find files relative to current buffer")
telescope_map("h", builtin.help_tags, "help")
telescope_map("b", builtin.buffers, "buffers")
telescope_map("B", function() builtin.live_grep({ grep_open_files = true }) end, "live grep, only open buffers")
telescope_map("g", builtin.live_grep, "live grep")
telescope_map("G", function() builtin.live_grep({ cwd = utils.buffer_dir() }) end, "live grep relative to current buffer")
telescope_map("o", builtin.oldfiles, "old files")
telescope_map("O", function() builtin.oldfiles({ cwd_only = true }) end, "Old files (relative to current pwd)")
telescope_map("q", builtin.quickfix, "quickfix list")
telescope_map("l", builtin.loclist, "local list")
telescope_map("m", builtin.diagnostics, "diagnostics")
telescope_map("d", builtin.diagnostics, "diagnostics")
telescope_map("c", builtin.command_history, "command history")
telescope_map("k", builtin.keymaps, "keymaps")
telescope_map("s", builtin.grep_string, "grep_string") -- note, this does a simple inclusive search, not \<\> search
telescope_map("y", builtin.lsp_document_symbols, "LSP document symbols")
telescope_map("Y", builtin.lsp_dynamic_workspace_symbols, "LSP dynamic workspace symbols")
telescope_map("i", builtin.vim_options, "vim options")
telescope_map("t", builtin.builtin, "telescope builtin")
telescope_map("r", builtin.resume, "telescope resume")
telescope_map("v", function() builtin.find_files({ hidden = true, cwd = "$HOME/.config/nvim/" }) end, "vim config files")
telescope_map("V", function() builtin.live_grep({ cwd = "~/.config/nvim/" }) end, "live grep relative to dotfiles")
telescope_map("]", builtin.tags, "telescope tags")

local function find_notes()
    builtin.live_grep({
        cwd = "~/notes/main",
        glob_pattern = "*.md",
    })
    -- initial search pattern for ya. this can be modified, unlike grep_string's 'search' field.
    -- vim.api.nvim_feedkeys("^#", "n", false)
end
vim.api.nvim_create_user_command("FindNotes", find_notes, {})
telescope_map("n", find_notes, "my notes, general")
telescope_map("N", function()
    builtin.tags({ cwd = "~/notes", ctags_file = "~/notes/tags" })
end, "my notes, tags only")
telescope_map("z", function()
    local link = vim.api.nvim_buf_get_name(0)
    local basename = vim.fs.basename(link)
    builtin.grep_string({ search = basename })
end, "my notes, backlinks search")

-- require("telescope").load_extension("undo")
-- vim.keymap.set("n", "<leader>fu", "<cmd>Telescope undo<cr>")

-- always ignore "tags" files, this makes my note backlink search work properly
vim.go.grepprg = "rg --vimgrep -uu --glob '!tags'"
