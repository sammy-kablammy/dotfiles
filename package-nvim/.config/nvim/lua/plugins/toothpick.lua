--[[

Toothpick is a minimal, single-file replacement for Harpoon
(https://github.com/ThePrimeagen/harpoon)

Vim has a builtin notion of the argument list (:h arglist) to manage frequently
used buffers. All Toothpick does is map Vim's argument list to a popup that can
be edited just like a normal text buffer. This means all your favorite Vim
operations (ddp to move a line down, ZZ to save+quit the window) work normally.

Notable differences from Harpoon:
- Arglist and cursor position are *NOT* saved between Nvim restarts. I already
  use session files (:h session-file), and they do this anyways.
- No fancy logging, no extensions, no Telescope integration

Another important point is that because we use sessions to store frequently used
files instead of the harpoon list, you can have multiple arglists in the same
directory (useful when alternating between two git branches that touch different
files).

--]]

-- TODO use autocmd groups for all autocmds here (and others around my config)

local function toothpick()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "arglist", { buf = bufnr })
    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = bufnr })
    -- Use the PID to create uniqueness in the buffer name, otherwise two vim
    -- instances couldn't open the popup in the same directory
    vim.api.nvim_buf_set_name(bufnr, "Toothpick" .. vim.fn.getpid())
    vim.api.nvim_create_autocmd({ "BufEnter" }, {
        buffer = bufnr,
        callback = function()
            -- Load arglist into popup
            vim.api.nvim_buf_set_lines(bufnr, 0, vim.fn.argc(), false, vim.fn.argv())
            vim.api.nvim_win_set_cursor(0, { 1, 0 })
        end,
    })

    -- Highlight settings for the arglist window title
    local ns_id = vim.api.nvim_create_namespace("arglist_title")
    vim.api.nvim_set_hl(ns_id, "ToothpickWindowTitle", { bold = true, })

    local get_window_dimensions = function()
        local width_scaling_factor = 0.5 -- (scaling factors are 0-1)
        local height_scaling_factor = 0.5 -- (scaling factors are 0-1)
        local win_width = vim.api.nvim_list_uis()[1].width
        local win_height = vim.api.nvim_list_uis()[1].height
        local width = math.floor(win_width * width_scaling_factor)
        local height = math.floor(win_height * height_scaling_factor)
        local col = (win_width - width) / 2
        local row = (win_height - height) / 2
        return {
            width = width,
            height = height,
            col = col,
            row = row,
        }
    end

    local dims = get_window_dimensions()
    local win_id = vim.api.nvim_open_win(bufnr, true, {
        width=dims.width,
        height=dims.height,
        col=dims.col,
        row=dims.row,
        relative='editor',
        border='single',
        title={ { 'Toothpick', 'ToothpickWindowTitle' } },
        title_pos='center',
        footer='bottom text',
        footer_pos='right',
    })
    vim.api.nvim_set_option_value("signcolumn", "no", { win = win_id })
    vim.api.nvim_set_option_value("colorcolumn", "", { win = win_id })
    vim.api.nvim_set_option_value("winfixbuf", true, { win = win_id })

    -- Store popup's contents in the actual arglist
    local save_to_arglist = function()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 999999, false)
        if vim.fn.argc() >= 1 then
            vim.cmd("1,$ argdelete") -- (delete all current args)
        end
        -- The reason we delete and re-add everything is that running :args will
        -- open the first entry. I want to keep the current buffer open.
        local argposition = 0
        for _, line in ipairs(lines) do
            local trimmed = vim.fn.trim(line)
            if trimmed ~= "" then
                local trimmed_with_spaces_escaped = vim.fn.substitute(trimmed, [[ ]], [[\\ ]], 'g')
                vim.cmd(argposition .. "argadd " .. trimmed_with_spaces_escaped)
                argposition = argposition + 1
            end
        end
        vim.cmd.argdedupe()
    end

    -- Close without saving. If you want to save, call save_to_arglist() first.
    local close_popup = function()
        if vim.api.nvim_win_get_buf(0) ~= bufnr then
            -- The arglist window is already closed. I don't know how we got
            -- here but there's nothing to do.
            return
        end
        -- note the second arg here to force close. this is how we write when we
        -- want to and don't write when we don't want to.
        vim.api.nvim_win_close(win_id, true)
        -- unset name because the next time popup is opened it would conflict
        vim.api.nvim_buf_set_name(bufnr, "")
    end
    vim.keymap.set("n", "<esc>", close_popup, { buffer = bufnr })
    vim.keymap.set("n", "<BS>", close_popup, { buffer = bufnr })
    vim.keymap.set("n", "q", close_popup, { buffer = bufnr })
    vim.keymap.set("n", "<C-c>", close_popup, { buffer = bufnr })

    -- create mappings to edit the selected file
    local choose_file = function(opener_command)
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        local file_to_edit = vim.fn.getline(cursor_line)
        save_to_arglist()
        close_popup()
        opener_command(file_to_edit)
    end
    vim.keymap.set("n", "<enter>", function() choose_file(vim.cmd.edit) end, { buffer = bufnr })
    vim.keymap.set("n", "<c-x>", function() choose_file(vim.cmd.split) end, { buffer = bufnr })
    vim.keymap.set("n", "<c-v>", function() choose_file(vim.cmd.vsplit) end, { buffer = bufnr })

    -- the popup window should resize properly when vim resizes
    vim.api.nvim_create_autocmd({ "VimResized" }, {
        buffer = bufnr,
        callback = function(ev)
            print("resize")
            -- vim.print(ev)
            local dimensions = get_window_dimensions()
            local config = vim.api.nvim_win_get_config(win_id)
            config.width = dimensions.width
            config.height = dimensions.height
            config.col = dimensions.col
            config.row = dimensions.row
            vim.api.nvim_win_set_config(win_id, config)
        end,
    })

    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
        buffer = bufnr,
        callback = function()
            save_to_arglist()
            close_popup()
        end,
    })

    -- this autocmd exists to handle selecting another window, like with <C-w>h
    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        buffer = bufnr,
        callback = close_popup,
    })
    -- this is necessary otherwise vim will complain about the toothpick buffer
    -- being unsaved when trying to exit vim
    vim.api.nvim_create_autocmd({ "QuitPre" }, {
        -- should NOT be buffer = bufnr here.
        buffer = bufnr,
        callback = function()
            if vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_delete(bufnr, { force = true })
            end
        end,
    })
end

-- TODO rename this to 'append' and make it's always appended to the correct spot
local function add_current_buf_to_arglist(file)
    local position = vim.fn.argc()
    vim.cmd(position .. "argadd")
    -- print("Added to arglist: '" .. vim.fn.expand("%") .. "'")
    print("Toothpicked " .. vim.fn.expand("%"))
    vim.cmd.argdedupe()
end

vim.api.nvim_create_user_command("Toothpick", toothpick, { desc = "Open Toothpick popup window" })

vim.keymap.set("n", "<leader>to", toothpick, { desc = "Toothpick Open popup" })
vim.keymap.set("n", "<leader>ta", add_current_buf_to_arglist, { desc = "Toothpick Add current buffer to arglist" })

-- vim.keymap.set("n", "<leader>re", toothpick, { desc = "aRglist edit" })
-- vim.keymap.set("n", "<leader>ra", add_current_buf_to_arglist, { desc = "aRglist add / ':argadd'" })

-- vim.keymap.set("n", "<leader>0", add_current_buf_to_arglist, { desc = "aRglist add / ':argadd'" }) -- holdover keybind from harpoon, will eventually delete

local function edit_arg_number(num)
    local args = vim.fn.argv()
    if num > #args then
        print("Argument number", num, "is not in the argument list.")
        return
    end
    -- You can't :edit or :argument the current file when it has unsaved
    -- changes. This is a vim thing so idk how to get around it. for now this
    -- behavior is weird.
    vim.cmd.argument(num)
end
vim.keymap.set("n", "<leader>1", function() edit_arg_number(1) end, { desc = "argument list 1" })
vim.keymap.set("n", "<leader>2", function() edit_arg_number(2) end, { desc = "argument list 2" })
vim.keymap.set("n", "<leader>3", function() edit_arg_number(3) end, { desc = "argument list 3" })
vim.keymap.set("n", "<leader>4", function() edit_arg_number(4) end, { desc = "argument list 4" })
vim.keymap.set("n", "<leader>5", function() edit_arg_number(5) end, { desc = "argument list 5" })
vim.keymap.set("n", "<leader>6", function() edit_arg_number(6) end, { desc = "argument list 6" })
vim.keymap.set("n", "<leader>7", function() edit_arg_number(7) end, { desc = "argument list 7" })
vim.keymap.set("n", "<leader>8", function() edit_arg_number(8) end, { desc = "argument list 8" })
vim.keymap.set("n", "<leader>9", function() edit_arg_number(9) end, { desc = "argument list 9" })

-- vim.keymap.set("n", "<k1>", function() edit_arg_number(1) end, { desc = "argument list 1" })
-- vim.keymap.set("n", "<k2>", function() edit_arg_number(2) end, { desc = "argument list 2" })
-- vim.keymap.set("n", "<k3>", function() edit_arg_number(3) end, { desc = "argument list 3" })
-- vim.keymap.set("n", "<k4>", function() edit_arg_number(4) end, { desc = "argument list 4" })

-- TODO if the current file is 1, and there are unsaved changes, pressing <>1
-- will error out. This should actually be a noop since you're already in the
-- right file.
