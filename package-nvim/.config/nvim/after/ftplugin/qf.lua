-- easy scrolling through quickfix list entries (inspired by undotree)

local is_qflist_actually_loclist = function(win_id)
    local wininfo = vim.fn.getwininfo(win_id)
    return wininfo ~= nil and wininfo[1] ~= nil and wininfo[1].loclist == 1
end

-- Some compiler errors take up multiple lines. All the lines relating to one
-- quickfix entry should be counted together
local get_number_of_quickfix_entries = function()
    local filtered = vim.tbl_filter(function(entry)
        return entry.valid == 1
    end, vim.fn.getqflist())
    return #filtered
end
-- 1-based because why not
local get_current_quickfix_entry_number = function()
    local entries = vim.fn.getqflist()
    local cursor_line_number = vim.fn.getqflist({ idx = 0 }).idx

    local entry_number = 0
    for i = 1, cursor_line_number do
        local entry = entries[i]
        if entry.valid == 1 then
            entry_number = entry_number + 1
        end
    end
    return entry_number
end

vim.keymap.set("n", "<c-n>", function()
    local win_id = vim.api.nvim_get_current_win()
    if get_current_quickfix_entry_number() >= get_number_of_quickfix_entries() then
        -- print("oob", get_current_quickfix_entry_number(), get_number_of_quickfix_entries())
        return
    end
    if is_qflist_actually_loclist(win_id) then
        vim.cmd.lnext()
    else
        vim.cmd.cnext()
    end
    vim.api.nvim_set_current_win(win_id)
end, { buffer = true })
vim.keymap.set("n", "<c-p>", function()
    local win_id = vim.api.nvim_get_current_win()
    if get_current_quickfix_entry_number() <= 1 then
        -- print("oob", get_current_quickfix_entry_number(), "was supposed to be <=1")
        return
    end
    if is_qflist_actually_loclist(win_id) then
        vim.cmd.lprev()
    else
        vim.cmd.cprev()
    end
    vim.api.nvim_set_current_win(win_id)
end, { buffer = true })
