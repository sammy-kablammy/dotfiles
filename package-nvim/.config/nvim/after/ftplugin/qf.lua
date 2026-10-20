-- easy scrolling through quickfix list entries (inspired by undotree)

local is_qflist_actually_loclist = function(win_id)
    local wininfo = vim.fn.getwininfo(win_id)
    return wininfo ~= nil and wininfo[1] ~= nil and wininfo[1].loclist == 1
end

vim.keymap.set("n", "<c-n>", function()
    local win_id = vim.api.nvim_get_current_win()
    local current_qf_position, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local total_qf_entries = vim.api.nvim_buf_line_count(0)
    if current_qf_position >= total_qf_entries then
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
    local current_qf_position, _ = unpack(vim.api.nvim_win_get_cursor(0))
    if current_qf_position <= 1 then
        return
    end
    if is_qflist_actually_loclist(win_id) then
        vim.cmd.lprev()
    else
        vim.cmd.cprev()
    end
    vim.api.nvim_set_current_win(win_id)
end, { buffer = true })
