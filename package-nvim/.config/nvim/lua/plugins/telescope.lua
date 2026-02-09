-- https://github.com/nvim-telescope/telescope.nvim
-- https://github.com/debugloop/telescope-undo.nvim

-- make sure you have ripgrep installed

local telescope = require("telescope")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
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
            prompt_position = 'bottom',
        },
        mappings = {
            n = {
                ["X"] = actions.delete_buffer,
                ["-"] = function()
                    -- resume telescope (really only intended for find_files) but with cwd set one level up
                    local bufnr = vim.fn.bufnr()
                    local query = action_state.get_current_line()
                    local state = action_state.get_current_picker(bufnr)
                    if state._selection_entry == nil then
                        return
                    end
                    -- idk if there's a better way to do this
                    local cwd = action_state.get_current_picker(bufnr)._selection_entry.cwd
                    -- there isn't a field called "hidden" in the state table, so just hardcode true for now
                    local include_hidden_files = true
                    local get_parent_dir = function(dir)
                        for i = #dir, 1, -1 do
                            local char = string.sub(dir, i, i)
                            if char == '/' then
                                rightmost_slash_idx = i
                                break
                            end
                        end
                        return string.sub(dir, 1, rightmost_slash_idx)
                    end
                    actions.close(bufnr)
                    builtin.find_files({
                        cwd = get_parent_dir(cwd),
                        hidden = true,
                        no_ignore = true,
                    })
                end,
            },
        },
    },
})

local function telescope_map(lhs, rhs, desc)
    vim.keymap.set("n", "<leader>f" .. lhs, rhs, { desc = desc })
end

-- telescope_map("f", function() builtin.find_files({ hidden = true }) end, "find files")
telescope_map("f", function() builtin.find_files() end, "find files")
telescope_map("F", function() builtin.find_files({ hidden = true, no_ignore = true, cwd = utils.buffer_dir() }) end, "find files relative to current buffer")
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

-- can't use vim.g.sam_notes_path here because it isn't defined yet???
vim.g.telescope_sam_notes_path = "/home/sam/kablam/notes"

local function find_notes()
    builtin.live_grep({
        cwd = vim.g.telescope_sam_notes_path .. "/main",
        glob_pattern = "*.md",
    })
    -- initial search pattern for ya. this can be modified, unlike grep_string's 'search' field.
    -- vim.api.nvim_feedkeys("^#", "n", false)
end
vim.api.nvim_create_user_command("FindNotes", find_notes, {})
telescope_map("n", find_notes, "my notes, general")
telescope_map("N", function()
    builtin.tags({ cwd = vim.g.telescope_sam_notes_path, ctags_file = vim.g.sam_notes_path .. "/tags" })
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
