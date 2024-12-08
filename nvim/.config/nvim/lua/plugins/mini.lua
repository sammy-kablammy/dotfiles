-- i would rather just use netrw but boy... the ability to preview files is
-- really useful. telescope's live_grep feature kinda does this but it requires
-- a search query. also just having the browser be a popup that supports vim
-- motions for editing files is nice.

local mini_files = require("mini.files")

vim.keymap.set("n", "<leader>e", function()
    print("try not to rely on this so much")
    mini_files.open(vim.api.nvim_buf_get_name(0), false)
end)

mini_files.setup({
    -- Customization of shown content
    content = {
        -- Predicate for which file system entries to show
        filter = nil,
        -- What prefix to show to the left of file system entry
        prefix = nil,
        -- In which order to show file system entries
        sort = nil,
    },

    -- Module mappings created only inside explorer.
    -- Use `''` (empty string) to not create one.
    -- see :h MiniFiles-navigation
    mappings = {
        -- go_in       = 'l',
        go_in = "<C-l>",
        -- go_in_plus  = 'L',
        go_in_plus = "<Enter>",
        -- go_out      = 'h',
        go_out = "-",
        -- go_out_plus = 'H',
        reset = "<BS>",
        reveal_cwd = "@", -- i don't know what this does
        show_help = "g?",
        synchronize = "=",
        -- trim_left = "<",
        -- trim_right = ">",
    },

    -- General options
    options = {
        -- Whether to delete permanently or move into module-specific trash
        -- permanent_delete = true,
        permanent_delete = false,
        -- Whether to use for editing directories
        use_as_default_explorer = true,
    },

    -- Customization of explorer windows
    windows = {
        -- Maximum number of windows to show side by side
        max_number = math.huge,
        -- Whether to show preview of file/directory under cursor
        preview = true,
        -- Width of focused window
        width_focus = 30,
        -- Width of non-focused window
        width_nofocus = 15,
        -- Width of preview window
        width_preview = 70,
    },
})

-- you can't make multiple bindings for the same action in the config above, so
-- we need a separate list of bindings down here.
-- https://github.com/echasnovski/mini.nvim/discussions/409
vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
        local map_buf = function(lhs, rhs)
            vim.keymap.set("n", lhs, rhs, { buffer = args.data.buf_id })
        end

        map_buf("<Leader>w", mini_files.synchronize)
        map_buf("<C-h>", mini_files.go_out)
        map_buf("<S-left>", mini_files.go_out)
        map_buf("<S-right>", mini_files.go_in)
        -- map_buf("p", mini_files.go_in) -- nope! p is already 'paste file'
        map_buf("q", mini_files.close)
        map_buf("<Esc>", mini_files.close)
        map_buf("<C-c>", mini_files.close)
        -- map_buf("<C-n>", mini_files.close)
        map_buf("<leader>e", mini_files.close)

        -- i keep accidentally pressing C-j and C-k and it closes the window lol
        map_buf("<C-j>", function() end)
        map_buf("<C-k>", function() end)

        -- Add extra mappings from *MiniFiles-examples*

        -- open file in a vsplit (why isn't this built in to the plugin?)
        -- lol it is built in, it's at the bottom
        -- vim.keymap.set('n', '<C-v>', function()
        --     mini_files.go_in()
        --     mini_files.close()
        --     -- TODO assumes vsplit direction is rightward,
        --     -- also assumes that <C-w>h uses the default binding,
        --     -- also assumes that the previous buffer is the one you want on the
        --     -- left
        --     vim.cmd('vsplit')
        --     -- pure sorcery is required to do ctrl keys within the :norm command
        --     vim.cmd([[exe "norm $\<C-w>h"]])
        --     vim.cmd('bp')
        --     vim.cmd([[exe "norm $\<C-w>l"]])
        -- end, { buffer = args.data.buf_id })
    end,
})

-- the following sectiond come from the mini-file.txt help file

--  Create mapping to show/hide dot-files
local show_dotfiles = true

local filter_show = function()
    return true
end

local filter_hide = function(fs_entry)
    return not vim.startswith(fs_entry.name, ".")
end

local toggle_dotfiles = function()
    show_dotfiles = not show_dotfiles
    local new_filter = show_dotfiles and filter_show or filter_hide
    mini_files.refresh({ content = { filter = new_filter } })
end

vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
        local buf_id = args.data.buf_id
        -- Tweak left-hand side of mapping to your liking
        vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
        vim.keymap.set("n", "gh", toggle_dotfiles, { buffer = buf_id })
    end,
})

-- actually, i can't get this to work
-- TODO

-- Create mappings to modify target window via split
-- local map_split = function(buf_id, lhs, direction)
--     local rhs = function()
--         -- Make new window and set it as target
--         local new_target_window
--         vim.api.nvim_win_call(mini_files.get_target_window(), function()
--             vim.cmd(direction .. ' split')
--             new_target_window = vim.api.nvim_get_current_win()
--         end)
--
--         mini_files.set_target_window(new_target_window)
--     end
--
--     -- Adding `desc` will result into `show_help` entries
--     local desc = 'Split ' .. direction
--     vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
-- end
--
-- vim.api.nvim_create_autocmd('User', {
--     pattern = 'MiniFilesBufferCreate',
--     callback = function(args)
--         local buf_id = args.data.buf_id
--         -- Tweak keys to your liking
--         map_split(buf_id, '<C-s>', 'belowright horizontal')
--         map_split(buf_id, '<C-v>', 'belowright vertical')
--     end,
-- })
