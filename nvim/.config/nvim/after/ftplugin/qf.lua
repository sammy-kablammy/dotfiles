-- easy scrolling through quickfix list entries (inspired by undotree)
-- note: doesn't work for loclist right now, i'll get to it eventually
vim.keymap.set("n", "<c-n>", function()
    local window = vim.api.nvim_get_current_win()
    local current_qf_position, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local total_qf_entries = vim.api.nvim_buf_line_count(0)
    if current_qf_position < total_qf_entries then
        vim.cmd.cnext()
    end
    -- re-focus the quickfix list, as it likes to unfocus itself
    vim.api.nvim_set_current_win(window)
end, { buffer = true })
vim.keymap.set("n", "<c-p>", function()
    local window = vim.api.nvim_get_current_win()
    local current_qf_position, _ = unpack(vim.api.nvim_win_get_cursor(0))
    if current_qf_position > 1 then
        vim.cmd.cprev()
    end
    -- re-focus the quickfix list, as it likes to unfocus itself
    vim.api.nvim_set_current_win(window)
end, { buffer = true })
