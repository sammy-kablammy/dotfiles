-- See :h commenting
local function comment_after()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    local current_line = vim.fn.getline(cursor[1])
    vim.fn.setline(cursor[1], current_line .. ' ' .. commentmarker .. ' ')
    vim.api.nvim_feedkeys("A", "n", true)
end
vim.keymap.set("n", "gcA", comment_after { desc = "comment after line" })
vim.keymap.set("n", "gca", comment_after { desc = "comment after line" })
vim.keymap.set("n", "gco", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    vim.fn.append(cursor[1], commentmarker .. ' ')
    vim.api.nvim_feedkeys("=jjA", "n", true)
end)
vim.keymap.set("n", "gcO", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    vim.fn.append(cursor[1] - 1, commentmarker .. ' ')
    vim.api.nvim_feedkeys("=kA", "n", true)
end)
